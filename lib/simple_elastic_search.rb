class SimpleElasticSearch
  SETTING = YAML.load_file("#{Rails.root}/config/elasticsearchsetting.yml")['elasticsearch']
  def self.format_content(person)
     
     search_content = ""
      if person["middle_name"].present?
         search_content = self.escape_single_quotes(person["middle_name"]) + ", "
      end 

      birthdate_formatted = person["birthdate"].to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      search_content = search_content + person["gender"].upcase + " "

  
      search_content = search_content + person["district"] + " " 
         

      if person["mother_first_name"].present?
        search_content = search_content + person["mother_first_name"] + " " 
      end

      if person["mother_middle_name"].present?
         search_content = search_content + person["mother_middle_name"] + " "
      end   

      if person["mother_last_name"].present?
        search_content = search_content + person["mother_last_name"] + " "
      end

      if person["father_first_name"].present?
         search_content = search_content + person["father_first_name"] + " "
      end 

      if person["father_middle_name"].present?
         search_content = search_content + person["father_middle_name"] + " "
      end 

      if person["father_last_name"].present?
         search_content = search_content + person["father_last_name"]
      end 

      return search_content.squish

  end

  def self.format_coded_content(person)
     
     search_content = ""
      if person["middle_name"].present?
         search_content = self.escape_single_quotes(person["middle_name"]).soundex + ", "
      end 

      birthdate_formatted = person["birthdate"].to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      search_content = search_content + person["gender"].upcase + " "

  
      search_content = search_content + person["district"] + " " 
         

      if person["mother_first_name"].present?
        search_content = search_content + person["mother_first_name"].soundex + " " 
      end

      if person["mother_middle_name"].present?
         search_content = search_content + person["mother_middle_name"].soundex + " "
      end   

      if person["mother_last_name"].present?
        search_content = search_content + person["mother_last_name"].soundex + " "
      end

      if person["father_first_name"].present?
         search_content = search_content + person["father_first_name"].soundex + " "
      end 

      if person["father_middle_name"].present?
         search_content = search_content + person["father_middle_name"].soundex + " "
      end 

      if person["father_last_name"].present?
         search_content = search_content + person["father_last_name"].soundex
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

     coded_content = "#{person["first_name"].soundex} #{person["last_name"].soundex} #{self.format_coded_content(person)}"

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

  def self.add(person)
    #puts self.elastic_format(person)
   puts `#{self.elastic_format(person)}`
  end

  def self.query(field,query_content,precision,size,from)
    if precision.blank?
      precision = SETTING['precision']
    end
    start_time = Time.now
    query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?size=#{size rescue 10}&from=#{from rescue 0}&pretty=true' -H 'Content-Type: application/json' -d'
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
      hits = self.query("coded_content",query_string,precision,10,0)["data"]
      hits.each do |hit|
        potential_duplicates << hit if hit["_id"] !=(person.person_id rescue nil)
      end

      return potential_duplicates
  end

  def self.count
    query = "curl -XGET 'http://#{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}/#{SETTING['type']}/_search?pretty=true'"
    data = JSON.parse(`#{query}`)["hits"]
    return data["total"]
  end
end