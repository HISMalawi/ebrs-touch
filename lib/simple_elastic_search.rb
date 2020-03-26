require "rails"
require "yaml"
class SimpleElasticSearch
  SETTING = YAML.load_file("#{Rails.root}/config/elasticsearchsetting.yml")['elasticsearch']
  def self.format_content(person)
     
     search_content = ""

      birthdate_formatted = person["birthdate"].to_date.strftime("%Y %m %d")
      search_content = search_content + birthdate_formatted + " "
      search_content = search_content + person["gender"].upcase + " "

  
      search_content = search_content + person["district"] + " " 
         

      if person["mother_first_name"].present?
        search_content = search_content + (person["mother_first_name"] rescue 'N/A').to_s + " " 
      end  

      if person["mother_last_name"].present?
        search_content = search_content +(person["mother_last_name"] rescue 'N/A').to_s + " "
      end

      return search_content.squish

  end

  def self.format_coded_content(person)
     
     search_content = ""

      birthdate_formatted = person["birthdate"].to_date.strftime("%Y %m %d")
      search_content = search_content + birthdate_formatted + " "
      search_content = search_content + person["gender"].upcase + " "

  
      search_content = search_content + person["district"] + " " 
         

      if person["mother_first_name"].present?
        search_content = search_content + (person["mother_first_name"].soundex rescue '').to_s + " " 
      end  

      if person["mother_last_name"].present?
        search_content = search_content + (person["mother_last_name"].soundex rescue '').to_s + " "
      end

      return search_content.squish

  end

  def self.escape_single_quotes(string)
    if string.present?
        string = string.gsub("'", "'\\\\''")
    end
    return string
  end

  def self.elastic_format(person)
     content =  self.format_content(person)
    
     registration_district = person["district"]

     coded_content = "#{person["first_name"].soundex rescue ''} #{person["last_name"].soundex rescue ''} #{self.format_coded_content(person)}"

     elastic_search_index = "curl -XPUT 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{person["id"]}'  -d '
              {
                \"first_name\": \"#{self.escape_single_quotes(person["first_name"])}\",
                \"last_name\": \"#{self.escape_single_quotes(person["last_name"])}\",
                \"middle_name\": \"#{self.escape_single_quotes(person["middle_name"]) rescue ''}\",
                \"gender\": \"#{person["gender"]}\",
                \"birthdate\": \"#{person["birthdate"].to_date.strftime("%Y-%m-%d")}\",
                \"place_of_death_district\": \"#{registration_district}\",
                \"mother_first_name\": \"#{self.escape_single_quotes(person["mother_first_name"])}\",
                \"mother_last_name\": \"#{self.escape_single_quotes(person["mother_last_name"])}\",
                \"father_first_name\": \"#{self.escape_single_quotes(person["father_first_name"])}\",
                \"father_last_name\": \"#{self.escape_single_quotes(person["father_last_name"])}\",
                \"coded_content\" :\"#{coded_content}\",
                \"content\" : \"#{self.escape_single_quotes(person["first_name"])} #{self.escape_single_quotes(person["last_name"])} #{escape_single_quotes(content)}\"
              }'"

      return elastic_search_index
  end

  def self.add_back(person)
    #puts self.elastic_format(person)
   puts `#{self.elastic_format(person)}`
  end

  def self.query(field,query_content,precision,size,from)
    if precision.blank?
      precision = SETTING['precision']
    end
    start_time = Time.now
    query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?size=#{size rescue 10}&from=#{from rescue 0}&pretty=true' -H 'Content-Type: application/json' -d'
            {
              \"query\": {
                  \"match\": {
                    \"#{field}\":{
                          \"query\":\"#{self.escape_single_quotes(query_content)}\",
                          \"minimum_should_match\": \"#{precision}%\"
                    }
                  }
                }
              }'"
      
      data = JSON.parse(`#{query}`)

      end_time = Time.now

      if data["error"].blank?
         return {"time" => (end_time-start_time), "data" => data["hits"]["hits"]}
      else
         return {"time" => (end_time-start_time), "data" => []}
      end
     
  end

  def self.query_duplicate(person,precision)
      content =  self.format_content(person)
      query_string = "#{person["first_name"]} #{person["last_name"]} #{content}"

      potential_duplicates = []
      hits = self.query("content",query_string,precision,10,0)["data"]

      hits.each do |hit|
        potential_duplicates << hit if hit["_id"] !=(person.person_id rescue nil)
      end

      return potential_duplicates
  end

  def self.query_duplicate_coded(person,precision)
      content =  self.format_coded_content(person)
      query_string = "#{person["first_name"].soundex} #{person["last_name"].soundex} #{content}"

      potential_duplicates = []
      hits = self.query("coded_content",query_string,60,15,0)["data"]
      
      #hits.each do |hit|
        #potential_duplicates << hit if hit["_id"].squish !=(person["person_id"].squish rescue nil)
      #end
      potential_duplicates = SimpleElasticSearch.white_similarity(person,hits,precision)
      return potential_duplicates
  end
  def self.white_similarity(person, hits,precision)

    potential_duplicates = []
    content =  "#{person["first_name"]} #{person["last_name"]} #{self.format_content(person)}"
    hits.each do |hit|
      next if hit["_id"].squish ==(person["id"].squish rescue nil)
      hit_content = hit["_source"]["content"]
      potential_hit = hit
      potential_hit["similarity_score"] = self.check_similarity_by_position(person,hit["_id"]).to_f
      if potential_hit["similarity_score"] >= precision.to_i
        potential_duplicates <<  hit
      end
      #WhiteSimilarity.similarity(content, hit_content) >= (precision/100)
    end

    return potential_duplicates
  end

  def self.check_similarity_by_position(newrecord,existingrecord_id)
    
    return 0 if existingrecord_id.to_s == "0"
      scores = {
                "name" => 2,
                "dob" => 3,
                "gender" => 1,
                "pob" => 1,
                "mother_name" => 2
      }

      score = 0
      #0. Records
      #newrecord = self.person_details(newrecord_id)
      person = self.person_details(existingrecord_id) rescue nil
      return 0 if person.blank?

      existingrecord = person

      # 1. Comparing person name
      newrecord_name = "#{newrecord['first_name']} #{newrecord['last_name']}"
      existingrecord_name = "#{existingrecord['first_name']} #{existingrecord['last_name']}"
      if newrecord_name.squish == existingrecord_name.squish
         score = score + 2 
      elsif newrecord['first_name'].squish == existingrecord['first_name'].squish
         score = score + 1 + WhiteSimilarity.similarity(newrecord['last_name'].squish, existingrecord['last_name'])
      elsif newrecord['last_name'].squish == existingrecord['last_name'].squish
         score = score + 1 + WhiteSimilarity.similarity(newrecord['first_name'].squish, existingrecord['first_name'])
      elsif newrecord['first_name'].squish == existingrecord['last_name'].squish
        score = score + 0.9 + WhiteSimilarity.similarity(newrecord['last_name'].squish, existingrecord['first_name'])
      elsif newrecord['last_name'].squish == existingrecord['first_name'].squish  
        score = score + 0.9 + WhiteSimilarity.similarity(newrecord['first_name'].squish, existingrecord['last_name'])
      else
         score = score + WhiteSimilarity.similarity(newrecord_name, existingrecord_name) * 2   
      end
     
      # 2. Comparing date of birth
      newrecord_birthdate = newrecord["birthdate"].to_date.strftime("%Y-%m-%d").split("-")
      existingrecord_birthdate = existingrecord["birthdate"].to_date.strftime("%Y-%m-%d").split("-")

      i = 0
      while i < newrecord_birthdate.length
          score = score + WhiteSimilarity.similarity(newrecord_birthdate[i], existingrecord_birthdate[i])
          i = i + 1
      end
      
      # 3. Comparing gender
      newrecord_gender = newrecord["gender"].first.upcase
      existingrecord_gender = existingrecord["gender"].first.upcase
      if newrecord_gender == existingrecord_gender
          score = score + 1
      else
          score = score + 0
      end

      # 4. comparing districts of birth
      newrecord_district = newrecord["district"]
      existingrecord_district = existingrecord["district"]
      score = score + WhiteSimilarity.similarity(newrecord_district, existingrecord_district)

      # 5. Comparing person mother's name
      newrecord_mother_name = "#{newrecord['mother_first_name']} #{newrecord['mother_last_name']}"
      existingrecord_mother_name = "#{existingrecord['mother_first_name']} #{existingrecord['mother_last_name']}"
      if newrecord_mother_name.squish == existingrecord_mother_name.squish
         score = score + 2 
      elsif newrecord['mother_first_name'].squish == existingrecord['mother_first_name'].squish
         score = score + 1 + WhiteSimilarity.similarity(newrecord['mother_last_name'].squish, existingrecord['mother_last_name'])
      elsif newrecord['mother_last_name'].squish == existingrecord['mother_last_name'].squish
         score = score + 1 + WhiteSimilarity.similarity(newrecord['mother_first_name'].squish, existingrecord['mother_first_name'])
      elsif newrecord['mother_first_name'].squish == existingrecord['mother_last_name'].squish
        score = score + 0.9 + WhiteSimilarity.similarity(newrecord['mother_last_name'].squish, existingrecord['mother_first_name'])
      elsif newrecord['mother_last_name'].squish == existingrecord['mother_first_name'].squish  
        score = score + 0.9 + WhiteSimilarity.similarity(newrecord['mother_first_name'].squish, existingrecord['mother_last_name'])
      else
         score = score + WhiteSimilarity.similarity(newrecord_mother_name, existingrecord_mother_name) * 2   
      end
      
      return (score / 9) * 100
  end

  def self.person_details(id)
      person = {}
      @core_person = CorePerson.find(id)
      @person = @core_person.person
      @name = @person.person_names.last
      @birth_details = PersonBirthDetail.where(person_id: @core_person.person_id).last
      @address = @person.addresses.last

      @mother_person = @person.mother
      @mother_address = @mother_person.addresses.last rescue nil
      @mother_name = @mother_person.person_names.last rescue ni

      person["id"] = @person.person_id.to_s
      person["first_name"]= @name.first_name rescue ''
      person["last_name"] =  @name.last_name rescue ''
      person["middle_name"] = @name.middle_name rescue ''
      person["gender"] = (@person.gender == 'F' ? 'Female' : 'Male')
      person["birthdate"]= @person.birthdate.to_date
      person["birthdate_estimated"] = @person.birthdate_estimated
      person["nationality"]=  @mother_person.citizenship rescue ''

      birth_loc = Location.find(@birth_details.birth_location_id)
      district = Location.find(@birth_details.district_of_birth)


      birth_location = birth_loc.name rescue nil

      @place_of_birth = birth_loc.name rescue nil

      @place_of_birth = @birth_details.other_birth_location if @place_of_birth.blank?

      person["place_of_birth"] = @place_of_birth
      if  @birth_details.district_of_birth.present?
        person["district"] = Location.find(@birth_details.district_of_birth).name
      else
        person["district"] = "Lilongwe"
      end
      person["mother_first_name"]= @mother_name.first_name rescue ''
      person["mother_last_name"] =  @mother_name.last_name  rescue ''
      person["mother_middle_name"] = @mother_name.middle_name rescue ''
      return person
  end
  def self.add(person)
    content =  self.format_content(person)
    
    registration_district = person["district"]

    coded_content = "#{person["first_name"].soundex} #{person["last_name"].soundex} #{self.format_coded_content(person)}"
    person["content"] = "#{self.escape_single_quotes(person["first_name"])} #{self.escape_single_quotes(person["last_name"])} #{content}"
    person["coded_content"] = coded_content
    create_string = self.escape_single_quotes(person.as_json.to_json)
    create_query = "curl -XPUT -s 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{person['id']}'  -d '
                #{create_string}'"
    `#{create_query}`             
    return self.find(person["id"])
  end

  #Retriving record from elastic research
  def self.find(id)
    find_query = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{id}' "
    begin
      record = JSON.parse(`#{find_query}`)
      return record["_source"].merge({"id" => record["_id"]}) 
    rescue Exception => e
      return {}
    end
  end
  
  def self.all(type="")
    find_all = "curl -s -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{type.present? ? type : SETTING['type']}/_search?pretty=true'"
    return JSON.parse(`#{find_all}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
  end

  def self.must_match_by(params)
    params_keys = params.keys rescue nil
    if params_keys.present?

      match = []
      params_keys.each do |key|
        match << {:match => { key => params[key]}}
      end
      query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              {
                \"query\": {
                  \"bool\": {
                    \"must\":#{self.escape_single_quotes(match.to_json.to_s)}
                    }
                  }
                }
              }'"
            return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
    else
      return "parameter bad format"
    end
  end

  def self.should_match_by(params)
    params_keys = params.keys rescue nil
    if params_keys.present?

      match = []
      params_keys.each do |key|
        match << {:match => { key => params[key]}}
      end
      query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              {
                \"query\": {
                  \"bool\": {
                    \"should\":#{self.escape_single_quotes(match.to_json.to_s)}
                    }
                  }
                }
              }'"
            return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
    else
      return "parameter bad format"
    end
  end

  def self.match_all(query_string)
    query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              {
                \"query\": {
                  \"match\": {
                    \"_all\":\"#{query_string}\"
                    }
                  }
                }
        }'"
        return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}
  end

  def self.match_by_query(query)
    query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'  -d '
              #{query.to_json.to_s}'"
        puts query
        return JSON.parse(`#{query}`)["hits"]["hits"].collect{|hit| hit["_source"].merge({"id" => hit["_id"]})}   
  end

  #Delete a document from elastic search
  def self.delete(id)
    delete_query = "curl -XDELETE 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{id}'"
    return JSON.parse(`#{delete_query}`)["found"]
  end

  #Update to elastic search
  def self.update(id,updates)
    document = self.find(id)
    if document.blank?
      puts "Document doesn't exist"
      return false
    else
      content = document
      content = content.merge(updates)
      update_query = "curl -XPUT 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/#{id}'  -d '
                #{content}'"
      return JSON.parse(`#{self.elastic_format(content)}`)["result"] == "updated" ? self.find(id) : false
    end
  end

  def self.count
    query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'"
    data = JSON.parse(`#{query}`)["hits"]
    return data["total"]
  end
end
