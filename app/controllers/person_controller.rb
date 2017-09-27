class PersonController < ApplicationController
  def index

    @icoFolder = icoFolder("icoFolder")
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
    @targeturl = "/logout"
    @targettext = "Logout"

    render :layout => 'facility'
  end

  def get_sync_status
    sync_progress  = '<span color: red !important>Sync Status: Offline</span>'
    @database = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
    source    = "#{@database['host']}:#{@database['port']}/#{@database['prefix']}_#{@database['suffix']}/"
    target    = "#{SETTINGS['sync_host']}/#{SETTINGS['sync_database']}/"
    data_link = "curl -X GET #{@database['protocol']}://#{@database['username']}:#{@database['password']}@#{@database['host']}:#{@database['port']}/_active_tasks"

    tasks     = JSON.parse(`#{data_link}`) rescue {}
    tasks.each do |task|

      next if task['type'] != 'replication'
      next if task['source'].split("@").last.strip != source.strip
      next if task['target'].split("@").last.strip != target.strip

      sync_progress = "Sync Status: #{task['progress']}%"
    end

    render text: sync_progress
  end

  def loc(id, tag=nil)
    tag_id = LocationTag.where(name: tag).last.id rescue nil
    result = nil
    if tag_id.blank?
      result = Location.find(id).name rescue nil
    else
      tagmap = LocationTagMap.where(location_tag_id: tag_id, location_id: id).last rescue nil
      if tagmap
        result = Location.find(tagmap.location_id).name rescue nil
      end
    end

    result
  end


  def show
    
    if params[:next_path].blank?
      @targeturl = request.referrer
    else
      @targeturl = params[:next_path]
    end

    @section = "View Record"

    @person = Person.find(params[:id])
    @core_person = CorePerson.find(params[:id])

    #New Variables

    @birth_details = PersonBirthDetail.where(person_id: @core_person.person_id).last
    @name = @person.person_names.last
    @address = @person.addresses.last

    @mother_person = @person.mother
    @mother_address = @mother_person.addresses.last rescue nil
    @mother_name = @mother_person.person_names.last rescue nil

    @father_person = @person.father
    @father_address = @father_person.addresses.last rescue nil
    @father_name = @father_person.person_names.last rescue nil

    @informant_person = @person.informant rescue nil
    @informant_address = @informant_person.addresses.last rescue nil
    @informant_name = @informant_person.person_names.last rescue nil

    @comments = PersonRecordStatus.where(" person_id = #{@person.id} AND COALESCE(comments, '') != '' ")
    days_gone = ((@birth_details.acknowledgement_of_receipt_date.to_date rescue Date.today) - @person.birthdate.to_date).to_i rescue 0
    @delayed =  days_gone > 42 ? "Yes" : "No"
    location = Location.find(SETTINGS['location_id'])
    facility_code = location.code
    birth_loc = Location.find(@birth_details.birth_location_id)
    district = Location.find(@birth_details.district_of_birth)

    birth_location = birth_loc.name rescue nil

    @place_of_birth = birth_loc.name rescue nil

    if birth_location == 'Other' && @birth_details.other_birth_location.present?
      @birth_details.other_birth_location
    end

    @place_of_birth = @birth_details.other_birth_location if @place_of_birth.blank?

    @status = PersonRecordStatus.status(@person.id)


    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, [@status])
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
    
    informant_rel = (!@birth_details.informant_relationship_to_person.blank? ?
        @birth_details.informant_relationship_to_person : @birth_details.other_informant_relationship_to_person) rescue nil

    @record = {
        "Details of Child" => [
            {
                "Birth Entry Number" => "#{@birth_details.ben rescue nil}",
                "Birth Registration Number" => "#{@birth_details.brn  rescue nil}"
            },
            {
                ["First Name", "mandatory"] => "#{@name.first_name rescue nil}",
                "Other Name" => "#{@name.middle_name rescue nil}",
                ["Surname", "mandatory"] => "#{@name.last_name rescue nil}"
            },
            {
                ["Date of birth", "mandatory"] => "#{@person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil}",
                ["Sex", "mandatory"] => "#{(@person.gender == 'F' ? 'Female' : 'Male')}",
                "Place of birth" => "#{loc(@birth_details.place_of_birth, 'Place of Birth')}"
            },
            {
                "Name of Hospital" => "#{loc(@birth_details.birth_location_id, 'Health Facility')}",
                "Other Details" => "#{@birth_details.other_birth_location}",
                "Address" => "#{@child.birth_address rescue nil}"
            },
            {
                "District" => "#{district.name}",
                "T/A" => "#{birth_loc.ta}",
                "Village" => "#{birth_loc.village rescue nil}"
            },
            {
                "Birth weight (kg)" => "#{@birth_details.birth_weight rescue nil}",
                "Type of birth" => "#{@birth_details.birth_type.name rescue nil}",
                "Other birth specified" => "#{@birth_details.other_type_of_birth rescue nil}"
            },
            {
                "Are the parents married to each other?" => "#{(@birth_details.parents_married_to_each_other.to_s == '1' ? 'Yes' : 'No') rescue nil}",
                "If yes, date of marriage" => "#{@birth_details.date_of_marriage.to_date.strftime('%d/%b/%Y')  rescue nil}"
            },

            {
                "Court Order Attached?" => "#{(@birth_details.court_order_attached.to_s == "1" ? 'Yes' : 'No') rescue nil}",
                "Parents Signed?" => "#{(@birth_details.parents_signed == "1" ? 'Yes' : 'No') rescue nil}",
                "Record Complete?" => "----"
            },
            {
                "Place where birth was recorded" => "#{loc(@birth_details.location_created_at)}",
                "Record Status" => "#{@status}",
                "Child/Person Type" => "#{@birth_details.reg_type.name}"
            }
        ],
        "Details of Child's Mother" => [
            {
                ["First Name", "mandatory"] => "#{@mother_name.first_name rescue nil}",
                "Other Name" => "#{@mother_name.middle_name rescue nil}",
                ["Maiden Surname", "mandatory"] => "#{@mother_name.last_name rescue nil}"
            },
            {
                "Date of birth" => "#{@mother_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil}",
                "Nationality" => "#{@mother_person.citizenship rescue nil}",
                "ID Number" => "#{@mother_person.id_number rescue nil}"
            },
            {
                "Physical Residential Address, District" => "#{loc(@mother_address.current_district, 'District') rescue nil}",
                "T/A" => "#{loc(@mother_address.current_ta, 'Traditional Authority') rescue nil}",
                "Village/Town" => "#{loc(@mother_address.current_village, 'Village') rescue nil}"
            },
            {
                "Home Address, District" => "#{loc(@mother_address.home_district, 'District') rescue nil}",
                "T/A" => "#{loc(@mother_address.home_ta, 'Traditional Authority') rescue nil}",
                "Village/Town" => "#{loc(@mother_address.home_village, 'Village') rescue nil}"
            },
            {
                "Gestation age at birth in weeks" => "#{@birth_details.gestation_at_birth rescue nil}",
                "Number of prenatal visits" => "#{@birth_details.number_of_prenatal_visits rescue nil}",
                "Month of pregnancy prenatal care started" => "#{@birth_details.month_prenatal_care_started rescue nil}"
            },
            {
                "Mode of delivery" => "#{@birth_details.mode_of_delivery.name rescue nil}",
                "Number of children born to the mother, including this child" => "#{@birth_details.number_of_children_born_alive_inclusive rescue nil}",
                "Number of children born to the mother, and still living" => "#{@birth_details.number_of_children_born_still_alive rescue nil}"
            },
            {
                "Level of education" => "#{@birth_details.level_of_education rescue nil}"
            }
        ],
        "Details of Child's Father" => [
            {
                "First Name" => "#{@father_name.first_name rescue nil}",
                "Other Name" => "#{@father_name.middle_name rescue nil}",
                "Surname" => "#{@father_name.last_name rescue nil}"
            },
            {
                "Date of birth" => "#{@father_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil}",
                "Nationality" => "#{@father_person.citizenship rescue nil}",
                "ID Number" => "#{@father_person.id_number rescue nil}"
            },
            {
                "Physical Residential Address, District" => "#{loc(@father_address.current_district, 'District') rescue nil}",
                "T/A" => "#{loc(@father_address.current_ta, 'Traditional Authority') rescue nil}",
                "Village/Town" => "#{loc(@father_address.current_village, 'Village') rescue nil}"
            },
            {
                "Home Address, District" => "#{loc(@father_address.home_district, 'District') rescue nil}",
                "T/A" => "#{loc(@father_address.home_ta, 'Traditional Authority') rescue nil}",
                "Village/Town" => "#{loc(@father_address.home_village, 'Village') rescue nil}"
            }
        ],
        "Details of Child's Informant" => [
            {
                "First Name" => "#{@informant_name.first_name rescue nil}",
                "Other Name" => "#{@informant_name.middle_name rescue nil}",
                "Family Name" => "#{@informant_name.last_name rescue nil}"
            },
            {
                "Relationship to child" => informant_rel,
                "ID Number" => "#{@informant_person.id_number rescue ""}"
            },
            {
                "Physical Address, District" => "#{loc(@informant_address.current_district, 'District') rescue nil}",
                "T/A" => "#{loc(@informant_address.current_ta, 'Traditional Authority') rescue nil}",
                "Village/Town" => "#{loc(@informant_address.current_village, 'Village') rescue nil}"
            },
            {
                "Postal Address" => "#{@informant_address.address_line_1 rescue nil}",
                "" => "#{@informant_address.address_line_2 rescue nil}",
                "City" => "#{@informant_address.city rescue nil}"
            },
            {
                "Phone Number" => "#{@informant_person.get_attribute('Cell Phone Number') rescue nil}",
                "Informant Signed?" => "#{(@birth_details.form_signed == 1 ? 'Yes' : 'No')}"
            },
            {
                "Acknowledgement Date" => "#{@birth_details.acknowledgement_of_receipt_date.to_date.strftime('%d/%b/%Y') rescue ""}",
                "Date of Registration" => "#{@birth_details.date_registered.to_date.strftime('%d/%b/%Y') rescue ""}",
                ["Delayed Registration", "sub"] => "#{@delayed}"
            }
        ]
    }



    @summaryHash = {

      "Child Name" => @person.name,
      "Child Gender" => ({'M' => 'Male', 'F' => 'Female'}[@person.gender.strip.split('')[0]] rescue @person.gender),
      "Child Date of Birth" => @person.birthdate.to_date.strftime("%d/%b/%Y"),
      "Place of Birth" => "#{Location.find(@birth_details.birth_location_id).name rescue nil}",
      "Child's Mother " => (@mother_person.name rescue nil),
      "Child's Father" =>  (@father_person.name rescue nil),
      "Parents Married" => (@birth_details.parents_married_to_each_other.to_s == '1' ? 'Yes' : 'No'),
      "Court order attached" => (@birth_details.court_order_attached.to_s == '1' ? 'Yes' : 'No'),
      "Parents signed?" => ((@birth_details.parents_signed rescue -1).to_s == '1' ? 'Yes' : 'No'),
      "Delayed Registration" => @delayed
    }

    if  (BirthRegistrationType.find(@person_details.birth_registration_type_id).name.upcase rescue nil) == 'ADOPTED'
      @summaryHash["Adoptive Mother"] = nil
      @summaryHash[ "Adoptive Father"] = nil
      @summaryHash["Adoption Court Order"] = nil
    end
    @results = []
    if ['FC-POTENTIAL DUPLICATE','DC-POTENTIAL DUPLICATE','DC-DUPLICATE'].include? @status && @folders.include?("Manage Duplicates")
        redirect_to "/potential/duplicate/#{@person.id}?index=0"
    else
        if @person.present? && SETTINGS['potential_search'] && SETTINGS['application_mode'] =="DC"

          person = {}
          person["person_id"] = @person.person_id.to_s
          person["first_name"]= @name.first_name rescue ''
          person["last_name"] =  @name.last_name rescue ''
          person["middle_name"] = @name.middle_name rescue ''
          person["gender"] = (@person.gender == 'F' ? 'Female' : 'Male')
          person["birthdate"]= @person.birthdate.to_date
          person["birthdate_estimated"] = @person.birthdate_estimated
          person["nationality"]=  @mother_person.citizenship
          person["place_of_birth"] = @place_of_birth
          if  birth_loc.district.present?
            person["district"] = birth_loc.district
          else
            person["district"] = "Lilongwe"
          end      
          person["mother_first_name"]= @mother_name.first_name rescue ''
          person["mother_last_name"] =  @mother_name.last_name  rescue ''
          person["mother_middle_name"] = @mother_name.middle_name rescue '' 
          person["father_first_name"]= @father_name.first_name  rescue ''
          person["father_last_name"] =  @father_name.last_name  rescue ''
          person["father_middle_name"] = @father_name.middle_name  rescue ''
        
          SimpleElasticSearch.add(person)

          if @status == "DC-ACTIVE"

            @results = []
            duplicates = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision']) 
            
            duplicates.each do |dup|
                next if DuplicateRecord.where(person_id: person['person_id']).present?
                @results << dup if PotentialDuplicate.where(person_id: dup['_id']).blank? 
            end
            
            if @results.present?
               potential_duplicate = PotentialDuplicate.create(person_id: @person.person_id,created_at: (Time.now))
               if potential_duplicate.present?
                     @results.each do |result|
                        potential_duplicate.create_duplicate(result["_id"])
                     end
               end
               #PersonRecordStatus.new_record_state(@person.person_id, "HQ-POTENTIAL DUPLICATE-TBA", "System mark record as potential duplicate")
               @status = "DC-POTENTIAL DUPLICATE" #PersonRecordStatus.status(@person.id)

            end      
          end
        else
             @results = []
        end
        render :layout => "facility"
    end

  end
  
  def records

   if application_mode == 'Facility'
      @states = ["DC-Complete"]
   else
      @states = ["DC-Active"]
   end
   

    @section = "New Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
  
    
    render :template => "person/records", :layout => "data_table"

  end

  def new

    @current_district = Location.find(SETTINGS['location_id']).district rescue nil

    $prev_child_id = params[:id]

    
    if params[:id].blank?
      
      @person = PersonName.new
      @person_details = PersonBirthDetail.new
      @type_of_birth = "Single"
      @section = "New Person"

    else

      @person = Person.find(params[:id])

      @person_details = PersonBirthDetail.find_by_person_id(params[:id])


      @person_name = PersonName.find_by_person_id(params[:id])

      @person_mother_name = @person.mother.person_names.first rescue nil

      @person_father_name = @person.father.person_names.first rescue nil

      if PersonBirthDetail.find_by_person_id(params[:id]).type_of_birth == 2
         @type_of_birth = "Second Twin"
      elsif PersonBirthDetail.find_by_person_id(params[:id]).type_of_birth == 4
         @type_of_birth = "Second Triplet"
      elsif PersonBirthDetail.find_by_person_id(params[:id]).type_of_birth == 5
         @type_of_birth = "Third Triplet"
      end
        
        
    end
     
     render :layout => "touch"
  end

  def create
    
    type_of_birth = params[:person][:type_of_birth]
    
     if type_of_birth == 'Twin'

        type_of_birth = 'First Twin'
        params[:person][:type_of_birth] = 'First Twin'

     elsif type_of_birth == 'Triplet'
      
         type_of_birth = 'First Triplet'  
         params[:person][:type_of_birth] = 'First Triplet'                                         
     end

     
    @person = PersonService.create_record(params)

    #To be contued
    if @person.present? && SETTINGS['potential_search']
      SimpleElasticSearch.add(person_for_elastic_search(params))
    else

    end
  

    if ["First Twin", "First Triplet", "Second Triplet"].include?(type_of_birth.strip)
      
      redirect_to "/person/new?id=#{@person.id}"

    else

       if application_mode == 'Facility'

          redirect_to '/view_cases'

        else

          redirect_to '/view_cases'

        end
    end

  end

  def update_person

    @person = Person.find(params[:id])
    
    @person_details = PersonBirthDetail.find_by_person_id(params[:id])
    
    @person_name = PersonName.find_by_person_id(params[:id])

    @person_mother_name = @person.mother.person_names.first rescue nil

    @person_father_name = @person.father.person_names.first rescue nil

    #raise PersonBirthDetail.find_by_person_id(params[:id]).birth_place.inspect

    if PersonBirthDetail.find_by_person_id(params[:id]).type_of_birth == 2
        @type_of_birth = "Second Twin"
    elsif PersonBirthDetail.find_by_person_id(params[:id]).type_of_birth == 4
        @type_of_birth = "Second Triplet"
    elsif PersonBirthDetail.find_by_person_id(params[:id]).type_of_birth == 5
        @type_of_birth = "Third Triplet"
    end
            
    @field = params['field']

    @section = "Update Record"

    render :layout => "touch"
  end

  def update
    if ["child_first_name","child_last_name","child_middle_name"].include?(params[:field])
      person_name = PersonName.find_by_person_id(params[:id])
      person_name.update_attributes(voided: true, void_reason: 'Amendment edited')
      person_name = PersonName.create(person_id: params[:id],
            first_name: params[:person][:first_name],
            last_name: params[:person][:last_name])
      redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases"
    end
    if ["child_birthdate","child_gender"].include?(params[:field])
      person = Person.find(params[:id])
      if params[:person][:gender][0] != person.gender
        person.gender = params[:person][:gender][0]
        person.save
      end

      if params[:person][:birthdate].to_date.to_s != person.birthdate.to_date.to_s
        person.birthdate = params[:person][:birthdate].to_date.to_s
        person.save
      end
       redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases"
    end
    
  end   

  def person_for_elastic_search(params)
      person = {}
      person["id"] = @person.person_id
      person["first_name"]= params[:person][:first_name]
      person["last_name"] =  params[:person][:last_name]
      person["middle_name"] = params[:person][:middle_name]
      person["gender"] = params[:person][:gender]
      person["birthdate"]= params[:person][:birthdate]
      person["birthdate_estimated"] = params[:person][:birthdate_estimated]

      if is_twin_or_triplet(params[:person][:type_of_birth].to_s)
         prev_child = Person.find(params[:person][:prev_child_id].to_i)
         if params[:relationship] == "opharned" || params[:relationship] == "adopted"
           mother = prev_child.adoptive_mother
         else
           mother = prev_child.mother
         end

         if mother.present?
            mother_name =  mother.person_names.first
         else
            mother_name = nil
         end
   
         person["mother_first_name"] = mother_name.first_name rescue ""
         person["mother_last_name"] =   mother_name.last_name rescue ""
         person["mother_middle_name"] =  mother_name.first_name rescue ""

         if params[:relationship] == "opharned" || params[:relationship] == "adopted"
           father = prev_child.adoptive_father
         else
           father = prev_child.father
         end

         if father.present?
            father_name =  father.person_names.first
         else
            father_name = nil
         end
         
         person["father_first_name"] = father_name.first_name rescue ""
         person["father_last_name"] =   father_name.last_name rescue ""
         person["father_middle_name"] = father_name.first_name rescue ""

         birth_details = prev_details = PersonBirthDetail.where(person_id: params[:person][:prev_child_id].to_i).first
         person["place_of_birth"] = Location.find(birth_details.place_of_birth).name
         person["district"] = Location.find(birth_details.district_of_birth).name
         person["nationality"]= Location.find(mother.addresses.first.citizenship).name rescue "Malawian"

      else

        person["place_of_birth"] = params[:person][:place_of_birth]
        person["district"] = params[:person][:birth_district]
        person["nationality"]=  params[:person][:mother][:citizenship]
        person["mother_first_name"]= params[:person][:mother][:first_name] rescue nil
        person["mother_last_name"] =  params[:person][:mother][:last_name] rescue nil
        person["mother_middle_name"] = params[:person][:mother][:middle_name] rescue nil
        person["father_first_name"]= params[:person][:father][:first_name] rescue nil
        person["father_last_name"] =  params[:person][:father][:last_name] rescue nil
        person["father_middle_name"] = params[:person][:father][:middle_name] rescue nil

      end
      return person
  end

  def is_twin_or_triplet(type_of_birth)
    if type_of_birth.include?"Second Twin" 
      return true 
    elsif type_of_birth.include?"Second Triplet" 
      return true 
    elsif type_of_birth.to_s.include? "Third Triplet"
      return true
    else
      return false
    end
  end

  def parents_married(parents_married,value)
    
    if parents_married == 1
        [value, "mandatory"]
    else
       return value
    end

  end

  #########################################################################
  ############### Duplicate search with elastic search ####################
 def search_similar_record
    
     if params[:twin_id].present? 
        birthdate = Person.where(person_id: params[:twin_id]).first.birthdate.to_time.to_s.split(" ")[0]
     else
        birthdate = (params[:birthdate].to_time.to_s.split(" ")[0] rescue params[:birthdate].to_time)
     end
      person = {
                      "first_name"=>params[:first_name], 
                      "last_name" => params[:last_name],
                      "middle_name" => (params[:middle_name] rescue nil),
                      "gender" => params[:gender],
                      "district" => params[:birth_district],
                      "birthdate"=> birthdate,
                      "mother_last_name" => (params[:mother_last_name] rescue nil),
                      "mother_middle_name" => (params[:mother_middle_name] rescue nil),
                      "mother_first_name" => (params[:mother_first_name] rescue nil),
                      "father_last_name" => (params[:father_last_name] rescue nil),
                      "father_middle_name" => (params[:father_middle_name] rescue nil),
                      "father_last_name" => (params[:father_last_name] rescue nil)
                  }


      if SETTINGS['potential_search']
        results = duplicate_search(person, params)
      else
        results = {:response => []}
      end
  

      if results[:response].count == 0
        render :text => {:response => false}.to_json
      else
        render :text => results.to_json
      end 

  end

  def duplicate_search(person, params)
      dupliates = SimpleElasticSearch.query_duplicate_coded(person,100)
      exact = false
      if dupliates.blank?
        if params[:type_of_birth] && is_twin_or_triplet(params[:type_of_birth])        
          dupliates = []
        else
          if params[:relationship] == "normal" || params[:relationship] == "adopted"
              dupliates = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision'])
          else
              dupliates = SimpleElasticSearch.query_duplicate_coded(person,"95")
          end
        end
      else
        exact  = true
      end
      return {:response => dupliates, :exact => exact}
  end
  
  def get_names
    entry = params["search"].soundex
    if params["last_name"]
      data = PersonName.where("last_name LIKE (?)", "#{params[:search]}%")
      if data.present?
        render text: data.collect(&:last_name).uniq.join("\n") and return
      else
        render text: "" and return
      end
    elsif params["first_name"]
      data = PersonName.where("first_name LIKE (?)", "#{params[:search]}%")
      if data.present?
        render text: data.collect(&:first_name).uniq.join("\n") and return
      else
        render text: "" and return
      end
    end

    render text: ''
  end

  def get_nationality
    nationality_tag = LocationTag.where(name: 'Country').first
    data = ['Malawian']
    Location.where("LENGTH(country) > 0 AND country != 'Malawian' AND country LIKE (?) AND m.location_tag_id = ?", 
      "#{params[:search]}%", nationality_tag.id).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('country ASC').map do |l|
      data << l.country
    end
    
    if data.present?
      render text: data.compact.uniq.join("\n") and return
    else
      render text: "" and return
    end
  end

  def get_country
    nationality_tag = LocationTag.where(name: 'Country').first
    data = ['Malawi']
    Location.where("LENGTH(name) > 0 AND country != 'Malawi' AND name LIKE (?) AND m.location_tag_id = ?", 
      "#{params[:search]}%", nationality_tag.id).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|
      data << l.name
    end
    
    if data.present?
      render text: data.compact.uniq.join("\n") and return
    else
      render text: "" and return
    end
  end

  def get_district
    nationality_tag = LocationTag.where(name: 'District').first
    data = []
    Location.where("LENGTH(name) > 0 AND name LIKE (?) AND m.location_tag_id = ?",
      "#{params[:search]}%", nationality_tag.id).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|
      data << l.name
    end
    
    if data.present?
      render text: data.compact.uniq.join("\n") and return
    else
      render text: "" and return
    end
  end

  def get_ta
    district_name = params[:district]
    nationality_tag = LocationTag.where(name: 'Traditional Authority').first
    location_id_for_district = Location.where(name: district_name).first.id

    data = []
    Location.where("LENGTH(name) > 0 AND name LIKE (?) AND m.location_tag_id = ? AND parent_location = ?", 
      "#{params[:search]}%", nationality_tag.id, location_id_for_district).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|
      data << l.name
    end
    
    if data.present?
      render text: data.compact.uniq.join("\n") and return
    else
      render text: "" and return
    end
  end

  def get_village
    district_name = params[:district]
    location_id_for_district = Location.where(name: district_name).first.id

    ta_name = params[:ta]
    location_id_for_ta = Location.where("name = ? AND parent_location = ?", 
      ta_name, location_id_for_district).first.id


    nationality_tag = LocationTag.where(name: 'Village').first
    data = []
    Location.where("LENGTH(name) > 0 AND name LIKE (?) AND m.location_tag_id = ?
      AND parent_location = ?", "#{params[:search]}%", nationality_tag.id,
      location_id_for_ta).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|
      data << l.name
    end
    
    if data.present?
      render text: data.compact.uniq.join("\n") and return
    else
      render text: "" and return
    end
  end

  def get_hospital
  map =  {'Mzuzu City' => 'Mzimba',
          'Lilongwe City' => 'Lilongwe',
          'Zomba City' => 'Zomba',
          'Blantyre City' => 'Blantyre'}

  if  (params[:district].match(/City$/) rescue false)
    params[:district] =map[params[:district]]
  end

  nationality_tag = LocationTag.where("name = 'Hospital' OR name = 'Health Facility'").first
  data = []
  parent_location = Location.where(" name = '#{params[:district]}' AND COALESCE(code, '') != '' ").first.id rescue nil

  Location.where("LENGTH(name) > 0 AND name LIKE (?) AND parent_location = #{parent_location} AND m.location_tag_id = ?",
    "#{params[:search]}%", nationality_tag.id).joins("INNER JOIN location_tag_map m
    ON location.location_id = m.location_id").order('name ASC').map do |l|
    data << l.name
  end
  
  if data.present?
    render text: data.compact.uniq.join("\n") and return
  else
    render text: "" and return
  end
 end

  def view_sync
     render :layout => "facility"
  end

  def view_cases

    if SETTINGS['application_mode'] == "FC"
        @states = ["DC-ACTIVE","FC-POTENTIAL DUPLICATE"]
    else
       @states = ["DC-ACTIVE"]
    end
    @section = "New Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @targeturl = "/manage_cases"
    @records = [] #PersonService.query_for_display(@states)
   
    render :template => "person/records", :layout => "data_table"
  end

  def view_complete_cases
    @states = ["DC-COMPLETE"]
    @section = "Complete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @targeturl = "/manage_cases"
    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_incomplete_cases
    @states = ["DC-INCOMPLETE"]
    @section = "Incomplete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @targeturl = "/manage_cases"
    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_pending_cases
    @states = ["DC-PENDING","DC-INCOMPLETE"]
    @section = "Pending Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_rejected_cases
    @states = ["DC-REJECTED"]
    @section = "Rejected Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_hq_rejected_cases
    @states = ["HQ-REJECTED"]
    @section = "Rejected Cases at HQ"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def edit

    if params[:next_path].blank?
      @targeturl = request.referrer
    else
      @targeturl = params[:next_path]
    end

    @section = "Edit Record"

    @person = Person.find(params[:id])
    @core_person = CorePerson.find(params[:id])

    #New Variables

    @birth_details = PersonBirthDetail.where(person_id: @core_person.person_id).last
    @name = @person.person_names.last
    @address = @person.addresses.last

    @mother_person = @person.mother
    @mother_address = @mother_person.addresses.last rescue nil
    @mother_name = @mother_person.person_names.last rescue nil

    @father_person = @person.father
    @father_address = @father_person.addresses.last rescue nil
    @father_name = @father_person.person_names.last rescue nil

    @informant_person = @person.informant rescue nil
    @informant_address = @informant_person.addresses.last rescue nil
    @informant_name = @informant_person.person_names.last rescue nil

    @comments = PersonRecordStatus.where(" person_id = #{@person.id} AND COALESCE(comments, '') != '' ")
    days_gone = ((@birth_details.acknowledgement_of_receipt_date.to_date rescue Date.today) - @person.birthdate.to_date).to_i rescue 0
    @delayed =  days_gone > 42 ? "Yes" : "No"
    location = Location.find(SETTINGS['location_id'])
    facility_code = location.code
    birth_loc = Location.find(@birth_details.birth_location_id)

    birth_location = birth_loc.name rescue nil

    @place_of_birth = birth_loc.name rescue nil

    if birth_location == 'Other' && @birth_details.other_birth_location.present?
      @birth_details.other_birth_location
    end

    @place_of_birth = @birth_details.other_birth_location if @place_of_birth.blank?

    @status = PersonRecordStatus.status(@person.id)

    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, [@status])
    informant_rel = (!@birth_details.informant_relationship_to_person.blank? ?
        @birth_details.informant_relationship_to_person : @birth_details.other_informant_relationship_to_person) rescue nil

    @record = {
        "Details of Child" => [
            {
                "Birth Entry Number" => "#{@birth_details.ben rescue nil}",
                "Birth Registration Number" => "#{@birth_details.brn  rescue nil}"
            },  
            {
                ["First Name","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_first_name"] => "#{@name.first_name rescue nil}",
                ["Other Name","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_middle_name"] => "#{@name.middle_name rescue nil}",
                ["Surname", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_surname"] => "#{@name.last_name rescue nil}"
            },
            {
                ["Date of birth", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_birthdate"] => "#{@person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil}",
                ["Sex", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_gender"] => "#{(@person.gender == 'F' ? 'Female' : 'Male')}",
                ["Place of birth","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_place_of_birth"] => "#{loc(@birth_details.place_of_birth, 'Place of Birth')}"
            },
            {
                ["Name of Hospital","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_hospital_of_birth"] => "#{loc(@birth_details.birth_location_id, 'Health Facility')}",
                ["Other Details","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_other_details"] => "#{@birth_details.other_birth_location}",
                ["Address","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_birth_address"] => "#{@child.birth_address rescue nil}"
            },
            {
                ["District", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_location_district"] => "#{birth_loc.district}",
                ["T/A", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_location_ta"] => "#{birth_loc.ta}",
                ["Village","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_location_village"] => "#{birth_loc.village rescue nil}"
            },
            {
                ["Birth weight (kg)","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_birth_weight"] => "#{@birth_details.birth_weight rescue nil}",
                ["Type of birth","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_birth_type"] => "#{@birth_details.birth_type.name rescue nil}",
                ["Other birth specified","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_other_birth_type"] => "#{@birth_details.other_type_of_birth rescue nil}"
            },
            {
                ["Are the parents married to each other?" ,"/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_parents_married_to_each_other"] => "#{(@birth_details.parents_married_to_each_other.to_s == '1' ? 'Yes' : 'No') rescue nil}",
                ["If yes, date of marriage","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_date_of_marriage"] => "#{@birth_details.date_of_marriage.to_date.strftime('%d/%b/%Y')  rescue nil}"
            },
            {
                ["Court Order Attached?","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_court_order_attached"] => "#{(@birth_details.court_order_attached.to_s == "1" ? 'Yes' : 'No') rescue nil}",
                ["Parents Signed?","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_parents_signed"] => "#{(@birth_details.parents_signed == "1" ? 'Yes' : 'No') rescue nil}",
                "Record Complete?" => "----"
            },
            {
                "Place where birth was recorded" => "#{loc(@birth_details.location_created_at)}",
                "Record Status" => "#{@status}",
                "Child/Person Type" => "#{@birth_details.reg_type.name}"
            }
        ],
        "Details of Child's Mother" => [
            {
                ["First Name", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_first_name"] => "#{@mother_name.first_name rescue nil}",
                ["Other Name", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_middle_name"] => "#{@mother_name.middle_name rescue nil}",
                ["Maiden Surname", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_maiden_name"] => "#{@mother_name.last_name rescue nil}"
            },
            {
                ["Date of birth", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_birth_date"] => "#{@mother_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil}",
                ["Nationality", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_citizenship"] => "#{@mother_person.citizenship rescue nil}",
                ["ID Number", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_id_number"] => "#{@mother_person.id_number rescue nil}"
            },
            {
                ["Physical Residential Address, District", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_address_current_district"] => "#{loc(@mother_address.current_district, 'District') rescue nil}",
                ["T/A", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_address_current_ta"] => "#{loc(@mother_address.current_ta, 'Traditional Authority') rescue nil}",
                ["Village/Town", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_address_current_village"] => "#{loc(@mother_address.current_village, 'Village') rescue nil}"
            },
            {
                ["District", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_address_home_district"] => "#{loc(@mother_address.home_district, 'District') rescue nil}",
                ["T/A", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_address_home_ta"] => "#{loc(@mother_address.home_ta, 'Traditional Authority') rescue nil}",
                ["Home Address, Village/Town", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_address_home_village"] => "#{loc(@mother_address.home_village, 'Village') rescue nil}"
            },
            {
                ["Gestation age at birth in weeks", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_gestation_at_birth"] => "#{@birth_details.gestation_at_birth rescue nil}",
                ["Number of prenatal visits", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_number_of_prenatal_visits"] => "#{@birth_details.number_of_prenatal_visits rescue nil}",
                ["Month of pregnancy prenatal care started", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_month_prenatal_care_started"] => "#{@birth_details.month_prenatal_care_started rescue nil}"
            },
            {
                ["Mode of delivery", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_mode_of_delivery"] => "#{@birth_details.mode_of_delivery.name rescue nil}",
                ["Number of children born to the mother, including this child", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_number_of_children_born_alive_inclusive"] => "#{@birth_details.number_of_children_born_alive_inclusive rescue nil}",
                ["Number of children born to the mother, and still living","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_number_of_children_born_still_alive"] => "#{@birth_details.number_of_children_born_still_alive rescue nil}"
            },
            {
                ["Level of education", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_level_of_education"] => "#{@birth_details.level_of_education rescue nil}"
            }
        ],
        "Details of Child's Father" => [
            {
                ["First Name", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_first_name"] => "#{@father_name.first_name rescue nil}",
                ["Other Name", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_middle_name"] => "#{@father_name.middle_name rescue nil}",
                ["Surname", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=person_surname" ] => "#{@father_name.last_name rescue nil}"
            },
            {
                ["Date of birth", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_birthdate"] => "#{@father_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil}",
                ["Nationality", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_citizenship"] => "#{@father_person.citizenship rescue nil}",
                ["ID Number", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_id_number"] => "#{@father_person.id_number rescue nil}"
            },
            {
                ["Physical Residential Address, District", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_address_current_district"] => "#{loc(@father_address.current_district, 'District') rescue nil}",
                ["T/A", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_address_current_ta"] => "#{loc(@father_address.current_ta, 'Traditional Authority') rescue nil}",
                ["Village/Town", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_address_current_village"] => "#{loc(@father_address.current_village, 'Village') rescue nil}"
            },
            {
                ["District", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_address_home_district"] => "#{loc(@father_address.home_district, 'District') rescue nil}",
                ["T/A", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_address_home_ta"] => "#{loc(@father_address.home_ta, 'Traditional Authority') rescue nil}",
                ["Home Address, Village/Town", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_address_current_village"] => "#{loc(@father_address.home_village, 'Village') rescue nil}"
            }
        ],
        "Details of Child's Informant" => [
            {
                ["First Name", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_first_name"] => "#{@informant_name.first_name rescue nil}",
                ["Other Name", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_middle_name"] => "#{@informant_name.middle_name rescue nil}",
                ["Family Name", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_family_name"] => "#{@informant_name.last_name rescue nil}"
            },
            {
                ["Relationship to child", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_relationship"] => informant_rel,
                ["ID Number","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_id_number"] => "#{@informant_person.id_number rescue ""}"
            },
            {
                ["Physical Address, District", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_address_home_district"] => "#{loc(@informant_address.home_district, 'District')rescue nil}",
                ["T/A","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_address_current_ta"] => "#{loc(@informant_address.current_ta, 'Traditional Authority') rescue nil}",
                ["Village/Town", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_address_current_village"] => "#{loc(@informant_address.current_village, 'Village') rescue nil}"
            },
            {
                ["Postal Address", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_address"] => "#{@informant_address.address_line_1 rescue nil}",
                "" => "#{@informant_address.address_line_2 rescue nil}",
                ["City", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_address_city"]  => "#{@informant_address.city rescue nil}"
            },
            {
                ["Phone Number", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=informant_cell_phone_number"]  => "#{@informant_person.get_attribute('Cell Phone Number') rescue nil}",
                ["Informant Signed?" , "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_form_signed"]  => "#{(@birth_details.form_signed == 1 ? 'Yes' : 'No')}"
            },
            {
                "Acknowledgement Date" => "#{@birth_details.acknowledgement_of_receipt_date.to_date.strftime('%d/%b/%Y') rescue ""}",
                "Date of Registration" => "#{@birth_details.date_registered.to_date.strftime('%d/%b/%Y') rescue ""}",
                "Delayed Registration" => "#{@delayed}"
            }
        ]
    }



    @summaryHash = {

      "Child Name" => @person.name,
      "Child Gender" => ({'M' => 'Male', 'F' => 'Female'}[@person.gender.strip.split('')[0]] rescue @person.gender),
      "Child Date of Birth" => @person.birthdate.to_date.strftime("%d/%b/%Y"),
      "Place of Birth" => "#{Location.find(@birth_details.birth_location_id).name rescue nil}",
      "Child's Mother " => (@mother_person.name rescue nil),
      "Child's Father" =>  (@father_person.name rescue nil),
      "Parents Married" => (@birth_details.parents_married_to_each_other.to_s == '1' ? 'Yes' : 'No'),
      "Court order attached" => (@birth_details.court_order_attached.to_s == '1' ? 'Yes' : 'No'),
      "Parents signed?" => ((@birth_details.parents_signed rescue -1).to_s == '1' ? 'Yes' : 'No'),
      "Delayed Registration" => @delayed
    }

    if  (BirthRegistrationType.find(@person_details.birth_registration_type_id).name.upcase rescue nil) == 'ADOPTED'
      @summaryHash["Adoptive Mother"] = nil
      @summaryHash[ "Adoptive Father"] = nil
      @summaryHash["Adoption Court Order"] = nil
    end

    render :layout => "facility"

  end  

  def view_printed_cases
    @states = ["HQ-PRINTED", 'HQ-DISPATCHED']
    @section = "Printed Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_voided_cases
    @states = ["DC-VOIDED"]
    @section = "Voided Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_approved_cases
    @states = Status.where("name like 'HQ-%' ").map(&:name) - ["HQ-REJECTED"]
    @section = "Approved Cases"
    @display_ben = true
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_dispatched_cases
    @states = ["HQ-DISPATCHED"]
    @section = "Voided Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def lost_and_damaged_cases
    @states = ["DC-LOST", 'DC-DAMAGED']
    @section = "Lost/Damaged Cases"
    @display_ben = true
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end


  def ammendment_cases
    @states = ['DC-AMEND']
    @section = "Ammendments"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def ammend_case
    @person = Person.find(params[:id])
    @prev_details = {}
    @birth_details = PersonBirthDetail.where(person_id: params[:id]).last

    @name = @person.person_names.last
    @person_prev_values = {}
    name_fields = ['first_name','last_name','middle_name',"gender","birthdate"]
    name_fields.each do |field|
        trail = AuditTrail.where(person_id: params[:id], field: field).order('created_at').last
        if trail.present?
            @person_prev_values[field] = trail.previous_value
        end
    end

    if @person_prev_values['first_name'].present? || @person_prev_values['last_name'].present?
        name = "#{@person_prev_values['first_name'].present? ? @person_prev_values['first_name'] : @name.first_name} "+
               "#{@person_prev_values['middle_name'].present? ? @person_prev_values['middle_name'] : (@name.middle_name rescue '')}" +
               "#{@person_prev_values['last_name'].present? ? @person_prev_values['last_name'] : @name.last_name}"
        @person_prev_values["person_name"] = name
    end
    @address = @person.addresses.last

    @mother_person = @person.mother
    @mother_name = @mother_person.person_names.last rescue nil
    @mother_prev_values = {}
    name_fields.each do |field|
        trail = AuditTrail.where(person_id: @mother_person.id, field: field).order('created_at').last
        if trail.present?
            @mother_prev_values[field] = trail.previous_value
        end
    end

    if @mother_prev_values['first_name'].present? || @mother_prev_values['last_name'].present?
        mother_name = "#{@mother_prev_values['first_name'].present? ? @mother_prev_values['first_name'] : @mother_name.first_name} "+
               "#{@mother_prev_values['middle_name'].present? ? @mother_prev_values['middle_name'] : (@mother_name.middle_name rescue '')}" +
               "#{@mother_prev_values['last_name'].present? ? @mother_prev_values['last_name'] : @mother_name.last_name}"
        @person_prev_values["mother_name"] = mother_name
    end

    @father_person = @person.father
    @father_name = @father_person.person_names.last rescue nil
    @father_prev_values = {}
    name_fields.each do |field|
        break if @father_person.blank?
        trail = AuditTrail.where(person_id: @father_person.id, field: field).order('created_at').last
        if trail.present?
            @father_prev_values[field] = trail.previous_value
        end
    end

    if @father_prev_values['first_name'].present? || @father_prev_values['last_name'].present?
        father_name = "#{@father_prev_values['first_name'].present? ? @father_prev_values['first_name'] : @father_name.first_name} "+
               "#{@father_prev_values['middle_name'].present? ? @father_prev_values['middle_name'] : (@father_name.middle_name rescue '')}" +
               "#{@father_prev_values['last_name'].present? ? @father_prev_values['last_name'] : @father_name.last_name}"
        @person_prev_values["father_name"] = mother_name
    end 

    @section = 'Ammend Case'
    render :layout => "facility"
  end

  def amend_edit
    @person = Person.find(params[:id])
    @birth_details = PersonBirthDetail.where(person_id: params[:id]).last
    @name = @person.person_names.last
    @address = @person.addresses.last

    @mother_person = @person.mother
    @mother_name = @mother_person.person_names.last rescue nil

    @father_person = @person.father
    @father_name = @father_person.person_names.last rescue nil
     @targeturl = "/person/ammend_case?id=#{params[:id]}"
    render :layout => "touch"
  end

  def amend_field
    fields = params[:fields].split(",")
    
    if fields.include? "Name"
      person_name = PersonName.find_by_person_id(params[:id])
      person_name.update_attributes(voided: true, void_reason: 'Amendment edited')
      person_name = PersonName.create(person_id: params[:id],
            first_name: params[:person][:first_name],
            last_name: params[:person][:last_name])
    end
    if fields.include? "Date of birth"
        person = Person.find(params[:id])
        person.update_attributes(birthdate: params[:person][:birthdate], birthdate_estimated: (params[:person][:birthdate_estimated]? params[:person][:birthdate_estimated] : 0))
    end
    if fields.include? "Sex"
       person = Person.find(params[:id])
        person.update_attributes(gender: params[:person][:gender])
    end
    if fields.include? "Place of birth"
    end
    if fields.include? "Name of mother"
        person = Person.find(params[:id])
        person_mother_name = person.mother.person_names.first
        person_mother_name.update_attributes(voided: true, void_reason: 'Amendment edited')
        person_mother_name = PersonName.create(person_id: person.mother.id,
            first_name: params[:person][:mother][:first_name],
            last_name: params[:person][:mother][:last_name])

        PersonNameCode.create(person_name_id: person_mother_name.person_name_id,
            first_name_code: params[:person][:mother][:first_name].soundex,
            last_name_code: params[:person][:mother][:last_name].soundex )
    end
    if fields.include? "Name of father"
        person = Person.find(params[:id])
        person_father_name = person.father.person_names.first

        if person_father_name.present?
          person_father_name.update_attributes(voided: true, void_reason: 'Amendment edited')
        end
        person_father_name = PersonName.create(person_id: person.mother.id,
              first_name: params[:person][:father][:first_name],
              last_name: params[:person][:father][:last_name])

        PersonNameCode.create(person_name_id: person_father_name.person_name_id,
              first_name_code: params[:person][:father][:first_name].soundex,
              last_name_code: params[:person][:father][:last_name].soundex )
    end
    redirect_to "/person/ammend_case?id=#{params[:id]}" 
  end

  def amendiment_comment
      render :layout => "touch"
  end
  def reprint_case
    @section = "Re-pring case"
  end

  def do_amend
    PersonRecordStatus.new_record_state(params['id'], "DC-AMEND", "Amendment request; #{params['reason']}");

    redirect_to (params[:next_path]? params[:next_path] : "/manage_requests")
  end

  def do_reprint
    PersonRecordStatus.new_record_state(params['id'], "DC-#{params['reason'].upcase}", "Reprint request; #{params['reason']}");

    redirect_to session['list_url']
  end

  def searched_cases
    @states = Status.all.map(&:name)
    @section = "Search Cases"
    @display_ben = true
    @search = true
    @user = User.find(params[:user_id])
    User.current = @user
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    filters = JSON.parse(params['data']) rescue {}
    @records = PersonService.search_results(filters)

    render :template => "person/records", :layout => "data_table"
  end
  #########################################################################

  def paginated_data
    params[:statuses] = [] if params[:statuses].blank?
    states = params[:statuses].split(',')
    types = []

    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?
    if !params[:start].blank?

      state_ids = states.collect{|s| Status.find_by_name(s).id} + [-1]

      if if params[:type] == 'All'
        types=['Normal', 'Abandoned', 'Adopted', 'Orphaned']
      else
        types=[params[:type]]
      end

      person_reg_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

      d = Person.order(" n.first_name, n.last_name, cp.created_at ")
      .joins(" INNER JOIN core_person cp ON person.person_id = cp.person_id
              INNER JOIN person_name n ON person.person_id = n.person_id
              INNER JOIN person_record_statuses prs ON person.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
              INNER JOIN person_birth_details pbd ON person.person_id = pbd.person_id ")
      .where(" prs.status_id IN (#{state_ids.join(', ')})
              AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')})
              AND concat_ws('_', pbd.national_serial_number, pbd.district_id_number, n.first_name, n.last_name, n.middle_name,
                person.birthdate, person.gender) REGEXP '#{search_val}' ")

      total = d.select(" count(*) c ")[0]['c'] rescue 0
      page = (params[:start].to_i / params[:length].to_i) + 1

      data = d.group(" prs.person_id ")

      data = data.select(" n.*, prs.status_id, pbd.district_id_number AS ben, person.gender, person.birthdate, pbd.national_serial_number AS brn, pbd.date_registered ")
      data = data.page(page)
      .per_page(params[:length].to_i)

      @records = []
      data.each do |p|
        mother = PersonService.mother(p.person_id)
        father = PersonService.father(p.person_id)
        details = PersonBirthDetail.find_by_person_id(p.person_id)

        name          = ("#{p['first_name']} #{p['middle_name']} #{p['last_name']}")
        mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
        father_name   = ("#{father.first_name rescue 'N/A'} #{father.middle_name rescue ''} #{father.last_name rescue ''}")
        row = []
        row = [p.ben] if params[:assign_ben] == 'true'
        row = row + [
            "#{name} (#{p.gender})",
            p.birthdate.strftime('%d/%b/%Y'),
            father_name,
            mother_name,
            p.date_registered.strftime('%d/%b/%Y'),
            Status.find(p.status_id).name,
            p.person_id
        ]
        @records << row
      end

      render :text => {
          "draw" => params[:draw].to_i,
          "recordsTotal" => total,
          "recordsFiltered" => total,
          "data" => @records}.to_json and return
    end

  end
end
end
