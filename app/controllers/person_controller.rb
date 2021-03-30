class PersonController < ApplicationController
  require 'open3'

  skip_before_action :verify_authenticity_token

  def index

    @icoFolder = icoFolder("icoFolder")
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
    @targeturl = "/logout"
    @targettext = "Logout"
    @stats = PersonRecordStatus.stats
    @role = User.current.user_role.role.role

    render :layout => 'facility'
  end

  def get_sync_status
    sync_progress  = '<span color: red !important>Sync Status: Offline</span>'
    @database = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
    source    = "#{@database['host']}:#{@database['port']}/#{@database['prefix']}_#{@database['suffix']}/"
    target    = "#{SETTINGS['sync_host']}/#{SETTINGS['sync_database']}/"
    data_link = "curl -s -X GET #{@database['protocol']}://#{@database['username']}:#{@database['password']}@#{@database['host']}:#{@database['port']}/_active_tasks"

    tasks     = JSON.parse(`#{data_link}`) rescue {}
    tasks.each do |task|
      task['target'] = task['target'].gsub(/localhost|127\.0\.0\.1/, '0.0.0.0')
      task['source'] = task['source'].gsub(/localhost|127\.0\.0\.1/, '0.0.0.0')
      target = target.gsub(/localhost|127\.0\.0\.1/, '0.0.0.0')
      source = source.gsub(/localhost|127\.0\.0\.1/, '0.0.0.0')

      next if task['type'] != 'replication'
      next if task['source'].split("@").last.strip != source.strip
      next if task['target'].split("@").last.strip != target.strip

      sync_progress = "Sync Status: #{task['progress']}%"
    end

    host, port = SETTINGS['sync_host'].split(":")
    a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
    if b.scan(/succeeded/).length > 0
      sync_progress += "<span style='color: white;'>Up</span>"
    else
      sync_progress += "<span style='color: white;'>Down</span>"
    end

    render text: sync_progress
  end

  def loc(id, tag=nil)
    location = Location.find(id)
    return location.name if location.present?
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

    @available_printers = SETTINGS["printer_name"].split('|')

    if params[:next_path].blank?
      @targeturl = request.referrer
    else
      @targeturl = params[:next_path]
    end

    @status = PersonRecordStatus.status(params[:id])

    if ["DC-POTENTIAL DUPLICATE","FC-POTENTIAL DUPLICATE","FC-EXACT DUPLICATE","DC-DUPLICATE"].include? @status
        redirect_to "/potential/duplicate/#{params[:id]}?next_path=/view_duplicates&index=0" and return
    end

    if ["DC-AMEND", "DC-AMEND-REJECTED"].include? @status
      redirect_to "/person/ammend_case?id=#{params[:id]}&next_path=/view_printed_cases" and return
    end

    @section = "View Record"

    @person = Person.find(params[:id])
    @core_person = CorePerson.find(params[:id])

    #New Variables

    @birth_details = PersonBirthDetail.where(person_id: @core_person.person_id).last
    @name = @person.person_names.first
    @address = @person.addresses.last

    @mother_person = @person.mother_all
    @mother_address = @mother_person.addresses.last rescue nil
    @mother_name = @mother_person.person_names.first rescue nil

    @father_person = @person.father_all
    @father_address = @father_person.addresses.last rescue nil
    @father_name = @father_person.person_names.first rescue nil

    @informant_person = @person.informant rescue nil
    @informant_address = @informant_person.addresses.last rescue nil
    @informant_name = @informant_person.person_names.first rescue nil

    @comments = PersonRecordStatus.where(" person_id = #{@person.id} AND COALESCE(comments, '') != '' ")
    days_gone = ((@birth_details.date_reported.to_date rescue Date.today) - @person.birthdate.to_date).to_i rescue 0
    @delayed =  days_gone > 42 ? "Yes" : "No"
    location = Location.find(SETTINGS['location_id'])
    facility_code = location.code

    birth_loc = Location.find(@birth_details.birth_location_id)
    birth_loc = nil if birth_loc.name == "Other"
    district_loc = Location.find(@birth_details.district_of_birth)

    other_place = nil
    district = nil
    ta       = nil
    village  = nil
    hospital = nil

    place = Location.find(@birth_details.place_of_birth).name
    if place == "Home"
      district = district_loc.name
      village = birth_loc.village rescue nil
      ta = birth_loc.ta rescue nil
      if village.blank? #Foreign Birth
        other_place = @birth_details.other_birth_location
      end
    elsif place == "Hospital"
      district = district_loc.name
      hospital = birth_loc.name rescue @birth_details.other_birth_location
    else
      district = district_loc.name
      other_place = @birth_details.other_birth_location
    end

    place_of_birth = "#{other_place}, #{village}, #{hospital}, #{ta}, #{district}".gsub(" ,", "").strip.gsub(/^,|^,\s+|,$|,\s+$/, "")
    @status = PersonRecordStatus.status(@person.id)

    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, [@status])
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
    
    informant_rel = (!@birth_details.informant_relationship_to_person.blank? ?
        @birth_details.informant_relationship_to_person : @birth_details.other_informant_relationship_to_person) rescue nil

    if @mother_person.present?
        mother_birth_date = @mother_person.birthdate.present? && @mother_person.birthdate.to_date.strftime('%Y-%m-%d') =='1900-01-01' ? 'N/A':  @mother_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil
    else
        mother_birth_date = nil
    end

    if @father_person.present?
        father_birth_date = @father_person.birthdate.present? && @father_person.birthdate.to_date.strftime('%Y-%m-%d') =='1900-01-01' ? 'N/A':  @father_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil
    else
        father_birth_date = nil
    end

    verification_number = @person.verification_number
    flag = ""
    if !verification_number.blank?
      flag = " <span style='color: green; font-weight: bold;'>  &nbsp;&nbsp;( Director Approval Number: #{verification_number}) </span>"
    end

    @record = {
        "Details of Child #{flag}".html_safe => [
            {
                "Birth Entry Number" => "#{@birth_details.ben rescue nil}",
                "Birth Registration Number" => "#{@birth_details.brn }",
                "ID Number" => "#{@person.id_number  rescue nil}"
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
                "Name of Hospital" => hospital,
                "Other Details" => other_place,
            },
            {
                "District/State" => district,
                "T/A" => ta,
                "Village" => village
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
                "Record Complete?" => (@birth_details.record_complete? rescue false) ? "<span id='c_yes' style='color: white; font-weight: bold;' >Yes</span>".html_safe : "<span id='c_no' style='font-weight: bold; color: white;' >No</span>".html_safe
            },
            {
                "Place where birth was recorded" => "#{loc(@birth_details.location_created_at)}",
                "Record Status" => "#{@status.sub("HQ-CAN-PRINT", "CAN-PRINT")}",
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
                "Date of birth" => "#{mother_birth_date}",
                "Nationality" => "#{@mother_person.citizenship rescue nil}",
                "ID Number" => "#{@mother_person.id_number rescue nil}"
            },
            {
                "Physical Residential Address, District" => "#{(loc(@mother_address.current_district, 'District') rescue @mother_address.current_district_other) rescue nil}",
                "T/A" => "#{(loc(@mother_address.current_ta, 'Traditional Authority') rescue @mother_address.current_ta_other) rescue nil}",
                "Village/Town" => "#{(loc(@mother_address.current_village, 'Village') rescue @mother_address.current_village_other) rescue nil}"
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
                "Date of birth" => "#{father_birth_date}",
                "Nationality" => "#{@father_person.citizenship rescue nil}",
                "ID Number" => "#{@father_person.id_number rescue nil}"
            },
            {
                "Physical Residential Address, District" => "#{(loc(@father_address.current_district, 'District') rescue @father_address.current_district_other) rescue nil}",
                "T/A" => "#{(loc(@father_address.current_ta, 'Traditional Authority') rescue @father_address.current_ta_other) rescue nil}",
                "Village/Town" => "#{(loc(@father_address.current_village, 'Village') rescue @father_address.current_village_other) rescue nil}"
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
                "Physical Address, District" => "#{(loc(@informant_address.current_district, 'District') rescue @informant_address.current_district_other) rescue nil}",
                "T/A" => "#{(loc(@informant_address.current_ta, 'Traditional Authority') rescue @informant_address.current_ta_other) rescue nil}",
                "Village/Town" => "#{(loc(@informant_address.current_village, 'Village') rescue @informant_address.current_village_other) rescue nil}"
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
                "Date Reported" => "#{@birth_details.date_reported.to_date.strftime('%d/%b/%Y') rescue ""}",
                "Date of Registration" => "#{@birth_details.date_registered.to_date.strftime('%d/%b/%Y') rescue ""}",
                ["Delayed Registration", "sub"] => "#{@delayed}"
            }
        ],
        "Details of Village Headman" => [
            {
                "Village Name" => (PersonAttribute.source_village(@person.person_id) rescue ""),
                "Village Headman Name" => (PersonAttribute.by_type(@person.person_id, "Village Headman Name") rescue ""),
                "Village Headman Signed" => (PersonAttribute.by_type(@person.person_id, "Village Headman Signature") rescue "")
            }
        ]
    }

    @trace_data = PersonRecordStatus.trace_data(@person.id)

    @summaryHash = {

        "Child Name" => @person.name,
        "Child Gender" => ({'M' => 'Male', 'F' => 'Female'}[@person.gender.strip.split('')[0]] rescue @person.gender),
        "Child Date of Birth" => @person.birthdate.to_date.strftime("%d/%b/%Y"),
        "Place of Birth" => place_of_birth,
        "Child's Mother " => (@mother_person.name rescue nil),
        "Mother Nationality " => (@mother_person.citizenship rescue "N/A"),
        "Child's Father" =>  (@father_person.name rescue nil),
        "Father Nationality" =>  (@father_person.citizenship rescue "N/A"),
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
          person["id"] = @person.person_id.to_s
          person["first_name"]= @name.first_name rescue ''
          person["last_name"] =  @name.last_name rescue ''
          person["middle_name"] = @name.middle_name rescue ''
          person["gender"] = (@person.gender == 'F' ? 'Female' : 'Male')
          person["birthdate"]= @person.birthdate.to_date.strftime('%Y-%m-%d')
          person["birthdate_estimated"] = @person.birthdate_estimated
          person["nationality"]=  @mother_person.citizenship rescue nil
          person["place_of_birth"] = @place_of_birth

          if  birth_loc.present? && birth_loc.district.present?
            person["district"] = birth_loc.district
          else

            if SETTINGS['application_mode'] == "DC"
              person["district"] = Location.find(SETTINGS['location_id']).name
            else
              person["district"] = Location.find(Location.find(SETTINGS['location_id']).parent_location).name rescue nil
            end

          end      

          person["mother_first_name"]= @mother_name.first_name rescue ''
          person["mother_last_name"] =  @mother_name.last_name  rescue ''
          person["mother_middle_name"] = @mother_name.middle_name rescue '' 

          person["mother_home_district"] = Location.find(@mother_person.addresses.last.home_district).name rescue nil
          person["mother_home_ta"] = Location.find(@mother_person.addresses.last.home_ta).name rescue nil
          person["mother_home_village"] = Location.find(@mother_person.addresses.last.home_village).name rescue nil

          person["mother_current_district"] = Location.find(@mother_person.addresses.last.current_district).name rescue nil
          person["mother_current_ta"] = Location.find(@mother_person.addresses.last.current_ta).name rescue nil
          person["mother_current_village"] = Location.find(@mother_person.addresses.last.current_village).name rescue nil


          person["father_first_name"]= @father_name.first_name  rescue ''
          person["father_last_name"] =  @father_name.last_name  rescue ''
          person["father_middle_name"] = @father_name.middle_name  rescue ''

          person["father_home_district"] = Location.find(@father_person.addresses.last.home_district).name rescue nil
          person["father_home_ta"] = Location.find(@father_person.addresses.last.home_ta).name rescue nil
          person["father_home_village"] = Location.find(@father_person.addresses.last.home_village).name rescue nil

          person["father_current_district"] = Location.find(@father_person.addresses.last.current_district).name rescue nil
          person["father_current_ta"] = Location.find(@father_person.addresses.last.current_ta).name rescue nil
          person["father_current_village"] = Location.find(@father_person.addresses.last.current_village).name rescue nil

          SimpleElasticSearch.add(person)

          if @status == "DC-ACTIVE"

            @results = []
            @exact = false
            duplicates = []
            #duplicates = SimpleElasticSearch.query_duplicate_coded(person,99.4) 

            if duplicates.blank?
              duplicates = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision']) 
            else
              @exact = true
            end


            duplicates.each do |dup|
                next if DuplicateRecord.where(person_id: person['id']).present?
                @results << dup if PotentialDuplicate.where(person_id: dup['_id']).blank? 
            end

            @results = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision'])
            
            if @results.present? && !@birth_details.birth_type.name.to_s.downcase.include?("twin")
               potential_duplicate = PotentialDuplicate.create(person_id: @person.person_id,created_at: (Time.now))
               if potential_duplicate.present?
                     @results.each do |result|
                        potential_duplicate.create_duplicate(result["_id"])
                     end
               end
               #PersonRecordStatus.new_record_state(@person.person_id, "HQ-POTENTIAL DUPLICATE-TBA", "System mark record as potential duplicate")
               if @exact
                 @status = "DC-DUPLICATE"
               else
                 @status = "DC-POTENTIAL DUPLICATE"
               end
               #PersonRecordStatus.status(@person.id)

            end      
          end
        else
             @results = []
        end

        if params[:bs_layout].to_s == "true"

          @online = false
          host, port = SETTINGS['sync_host'].split(":")
          a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
          if b.scan(/succeeded/).length > 0
            @online = true
          end

          render :layout => "bootstrap_data_table", :template => "person/bootstrap_show"
        else params[:preview].blank?
          render :layout => "facility"
        end
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

    #@records = PersonService.query_for_display(@states)
    
    render :template => "person/records", :layout => "data_table"

  end

  def new

    if  SETTINGS["application_mode"] == "FC"
        @current_district = Location.find(Location.find(SETTINGS["location_id"]).parent_location).name
    else
        @current_district = Location.find(SETTINGS['location_id']).name rescue nil
    end

    @role = User.current.user_role.role.role
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

    exact_duplicates = PersonService.exact_duplicates(params)

    if exact_duplicates.blank?
        @person = PersonService.create_record(params)
    else

      session[:exact_duplicate_data] = params
      redirect_to "/record_exists?person_ids=#{exact_duplicates.join(',')}" and return
    end

    if @person.present? && SETTINGS['potential_search']
      SimpleElasticSearch.add(person_for_elastic_search(@person,params))
    else

    end
  
    if User.current.user_role.role.role == "Data Supervisor"
      redirect_to "/above_16_abroad" and return
    end

    if ["First Twin", "First Triplet", "Second Triplet"].include?(type_of_birth.strip)

      if application_mode == 'Facility'
        print_registration(@person.id, "/person/new?id=#{@person.id}") and return
      else
        redirect_to "/person/new?id=#{@person.id}" and return
      end

    else

       if application_mode == 'Facility'
         print_registration(@person.id, '/view_cases') and return
        else
          redirect_to '/view_cases' and return
        end
    end

  end

  def record_exists
    @exact_duplicates = []

    person_ids = params[:person_ids].split(",")
    person_ids.each do |person_id|

      person        = Person.find(person_id)
      person_name   = PersonName.where(person_id: person_id).first
      mother        = PersonService.mother(person_id) rescue nil
      father        = PersonService.father(person_id) rescue nil
      status        = PersonRecordStatus.status(person_id)

      mother_address = PersonAddress.where(person_id: mother.person_id).first #rescue nil
      mother_home_district = Location.find(mother_address.home_district).name rescue nil
      mother_home_district = mother_address.home_district_other if mother_home_district.blank? && mother_address.present?

      @exact_duplicates << {
          'first_name'  => person_name.first_name,
          'last_name'   => person_name.last_name,
          'middle_name' => person_name.middle_name,
          'birthdate'   => person.birthdate.to_date.strftime("%d-%b-%Y"),
          'gender'      => ({'M' => 'Male', 'F' => 'Female', 'N/A' => 'N/A'}[person.gender]),
          'mother_name' => (Person.find(mother.person_id).name rescue "N/A"),
          'father_name' => (Person.find(father.person_id).name rescue "N/A"),
          'mother_home_district' => mother_home_district,
          'record_status'        => status
      }
    end
  end

  def save_exact_duplicate

    data = session[:exact_duplicate_data].with_indifferent_access

    type_of_birth = data[:person][:type_of_birth]

    if type_of_birth == 'Twin'

      type_of_birth = 'First Twin'
      params[:person][:type_of_birth] = 'First Twin'

    elsif type_of_birth == 'Triplet'

      type_of_birth = 'First Triplet'
      data[:person][:type_of_birth] = 'First Triplet'
    end

    data[:person][:is_exact_duplicate] = true
    data[:person][:duplicate] = params[:person_ids]

    @person = PersonService.create_record(data)

    if @person.present? && SETTINGS['potential_search']
      SimpleElasticSearch.add(person_for_elastic_search(@person,data))
    end

    if User.current.user_role.role.role == "Data Supervisor"
      redirect_to "/above_16_abroad" and return
    end

    if ["First Twin", "First Triplet", "Second Triplet"].include?(type_of_birth.strip)

      if application_mode == 'Facility'
        print_registration(@person.id, "/person/new?id=#{@person.id}") and return
      else
        redirect_to "/person/new?id=#{@person.id}" and return
      end

    else

      if application_mode == 'Facility'
        print_registration(@person.id, '/view_cases') and return
      else
        redirect_to '/view_cases' and return
      end
    end
  end

  def update_person

    @person = Person.find(params[:id])

    @core_person = CorePerson.find(params[:id])

    @person_details = PersonBirthDetail.find_by_person_id(params[:id])
    
    @person_name = PersonName.find_by_person_id(params[:id])

    @person_mother_name = @person.mother.person_names.first rescue nil

    @person_father_name = @person.father.person_names.first rescue nil

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

  def create_adoptive_parents

  end

  def get_people_by_birth_entry_number

    from_details = PersonBirthDetail.where(district_id_number: params['value']).pluck("person_id")
    from_pidentifiers = PersonIdentifier.where(
                        value: params['value'],
                        person_identifier_type_id: PersonIdentifierType.where(
                            name: "Old Birth Entry Number").last.id).pluck("person_id")

    person_ids = (from_details + from_pidentifiers).uniq
    render :text => person_ids.to_json
  end

  def update

    if ["child_first_name","child_surname","child_middle_name"].include?(params[:field])
      person_name = PersonName.find_by_person_id(params[:id])
      if params[:person][:first_name] != person_name.first_name  || params[:person][:last_name] != person_name.last_name || params[:person][:middle_name] != person_name.middle_name
        person_name.update_attributes(voided: true, void_reason: 'General edit')
        person_name = PersonName.create(person_id: params[:id],
              first_name: params[:person][:first_name],
              middle_name: params[:person][:middle_name],
              last_name: params[:person][:last_name])

      end
      redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
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
       redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
    end

    if ["birth_details_hospital_of_birth","birth_details_place_of_birth","birth_details_other_details","birth_location_district","birth_location_ta","birth_location_village"].include?(params[:field])

      map =  {'Mzuzu City' => 'Mzimba',
              'Lilongwe City' => 'Lilongwe',
              'Zomba City' => 'Zomba',
              'Blantyre City' => 'Blantyre'}

      d_name = params[:person][:birth_district]
      d_name = map[params[:person][:birth_district]] if params[:person][:birth_district].match(/City$/)

      place_of_birth    = params[:person][:place_of_birth]
      place_of_birth_id = Location.where(name: place_of_birth).first.id

      other_birth_place = nil
      birth_location_id = nil
      district_id       = nil
      foreign_birth     = false

      district_id = Location.locate_id_by_tag(params[:person][:birth_district], 'District')

      district_id_raw = Location.locate_id_by_tag(d_name, 'District')

      if district_id_raw.blank?
        foreign_birth = true
        district_id_raw = Location.locate_id_by_tag(params[:person][:birth_country], 'Country')
      end

      if place_of_birth == 'Home'

        if !foreign_birth
          ta_id               = Location.locate_id(params[:person][:birth_ta], 'Traditional Authority', district_id)
          birth_location_id   = Location.locate_id(params[:person][:birth_village], 'Village', ta_id)
        else
          birth_location_id   = Location.where(name: "Other").first.id
          other_birth_place   = params[:person][:other_birth_place_details]
        end
      elsif place_of_birth == 'Hospital'

        params[:person][:birth_district] = map[params[:person][:birth_district]] if params[:person][:birth_district].match(/City$/)

        if  !foreign_birth
          d_id = Location.locate_id_by_tag(params[:person][:birth_district], 'District')
          birth_location_id = Location.locate_id(params[:person][:hospital_of_birth], 'Health Facility', d_id)

          if birth_location_id.blank?
            birth_location_id   = Location.where(name: "Other").first.id
            other_birth_place   = params[:person][:other_birth_place_details]
          end
        else
          birth_location_id   = Location.where(name: "Other").first.id
          other_birth_place   = params[:person][:other_birth_place_details]
        end

      else #Other

        birth_location_id   = Location.where(name: "Other").first.id
        other_birth_place   = params[:person][:other_birth_place_details]
      end

      birth_details                       = PersonBirthDetail.where(person_id: params[:id]).last
      birth_details.district_of_birth     = district_id_raw
      birth_details.birth_location_id     = birth_location_id
      birth_details.other_birth_location  = other_birth_place
      birth_details.place_of_birth        = place_of_birth_id
      birth_details.save

      redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
      #raise params.inspect
    end

    if ["birth_details_birth_weight","birth_details_birth_type","birth_details_other_birth_type","birth_details_gestation_at_birth","birth_details_number_of_prenatal_visits", "birth_details_month_prenatal_care_started","birth_details_mode_of_delivery"].include?(params[:field])
   
      birth_details = PersonBirthDetail.where(person_id: params[:id]).last

      if params[:person][:birth_weight].present? && birth_details.birth_weight.to_i != params[:person][:birth_weight].to_i
        birth_details.birth_weight = params[:person][:birth_weight]
      end


      if params[:person][:type_of_birth].present?
        person_type_of_birth = PersonTypeOfBirth.where(name: params[:person][:type_of_birth]).last.person_type_of_birth_id
        birth_details.type_of_birth = person_type_of_birth
        if params[:person][:type_of_birth] == "Other"
          birth_details.other_type_of_birth = params[:person][:other_type_of_birth]
        end
      end

      if params[:person][:gestation_at_birth].present?
        birth_details.gestation_at_birth = params[:person][:gestation_at_birth]
      end

      if params[:person][:number_of_prenatal_visits].present?
        birth_details.number_of_prenatal_visits = params[:person][:number_of_prenatal_visits]
      end

      if params[:person][:month_prenatal_care_started].present?
        birth_details.month_prenatal_care_started = params[:person][:month_prenatal_care_started]
      end

      if params[:person][:mode_of_delivery].present?
        delivery_mode = ModeOfDelivery.find_by_name(params[:person][:mode_of_delivery]).id
        birth_details.mode_of_delivery_id = delivery_mode
      end

      if birth_details.save
        redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
      end
    end

    if ["birth_details_number_of_children_born_alive_inclusive","birth_details_number_of_children_born_still_alive","birth_details_level_of_education"].include?(params[:field])
        birth_details = PersonBirthDetail.where(person_id: params[:id]).last

        if params[:person][:number_of_children_born_still_alive].present?
           birth_details.number_of_children_born_still_alive = params[:person][:number_of_children_born_still_alive]
        end
        
        if params[:person][:number_of_children_born_alive_inclusive].present?
          birth_details.number_of_children_born_alive_inclusive = params[:person][:number_of_children_born_alive_inclusive]
        end

        if params[:person][:level_of_education].present?
            level_of_education = LevelOfEducation.find_by_name(params[:person][:level_of_education]).id
            birth_details.level_of_education_id = level_of_education
        end

        if birth_details.save
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
        end
    end

    if ["birth_details_court_order_attached","birth_details_parents_signed","birth_details_parents_married_to_each_other","birth_details_date_of_marriage"  ].include?(params[:field])
      birth_details = PersonBirthDetail.where(person_id: params[:id]).last
      if params[:person][:parents_married_to_each_other].present? 
          birth_details.parents_married_to_each_other = (params[:person][:parents_married_to_each_other] == "Yes" ? 1 : 0)
          if params[:person][:parents_married_to_each_other] == "Yes"
            birth_details.court_order_attached = 0
            birth_details.parents_signed = 0
          end
      end

      if params[:person][:date_of_marriage].present?
          if params[:person][:parents_married_to_each_other] == "No"
            birth_details.date_of_marriage =  nil
          else  
            birth_details.date_of_marriage = params[:person][:date_of_marriage].to_date.to_s rescue nil
          end
          
      end

      if params[:person][:court_order_attached].present?
        birth_details.court_order_attached = (params[:person][:court_order_attached] == "Yes" ? 1 : 0)
      end

      if params[:person][:parents_signed].present?
        birth_details.parents_signed = (params[:person][:parents_signed] == "Yes" ? 1 : 0)
      end

      if birth_details.save
        redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
      end
    end

    if ["mother_last_name","mother_first_name", "mother_middle_name", "mother_maiden_name", "mother_id_number","mother_birth_date"].include?(params[:field])
          person_mother = Person.find(params[:id]).mother
          person_mother_name = PersonName.find_by_person_id(person_mother.id)
          if params[:person][:mother][:first_name] != person_mother_name.first_name  || params[:person][:mother][:last_name] != person_mother_name.last_name || params[:person][:mother][:middle_name] != person_mother_name.middle_name
            person_mother_name.update_attributes(voided: true, void_reason: 'General edit')
            person_mother_name = PersonName.create(person_id: person_mother.id,
                  first_name: params[:person][:mother][:first_name],
                  middle_name: params[:person][:mother][:middle_name],
                  last_name: params[:person][:mother][:last_name])
          end
          
          if params[:person][:mother][:id_number].present?
              identifier_type = PersonIdentifierType.find_by_name("National ID Number").id
              
              mother_identifier = PersonIdentifier.where(person_id: person_mother.id, person_identifier_type_id: identifier_type).last
              
              if mother_identifier.present?
                 mother_identifier.update_attributes(value: params[:person][:mother][:id_number])
              else
                PersonIdentifier.create(
                          person_id: mother_person.person_id,
                          person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
                          value: params[:person][:mother][:id_number]
                  )
              end
          end

          if params[:person][:mother][:birthdate].present?
              person_mother.birthdate = params[:person][:mother][:birthdate].to_date.to_s
              person_mother.save
          end

          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
    end


    if ["mother_address_current_district","mother_address_current_ta", "mother_address_current_village","mother_citizenship"].include?(params[:field])
        person_mother = Person.find(params[:id]).mother
        person_address = PersonAddress.find_by_person_id(person_mother.id)
        if params[:person][:mother][:citizenship].present?
          person_address.citizenship = Location.find_by_country(params[:person][:mother][:citizenship]).id
        end
        if params[:person][:mother][:residential_country].present?
          person_address.residential_country = Location.find_by_name(params[:person][:mother][:residential_country]).id
        end
        if params[:person][:mother][:current_district].present?
          person_address.current_district  = Location.find_by_name(params[:person][:mother][:current_district]).id
        end
        if params[:person][:mother][:current_ta].present?
          person_address.current_ta = Location.find_by_name(params[:person][:mother][:current_ta]).id
        end
        if params[:person][:mother][:current_village].present?
          person_address.current_village = Location.find_by_name(params[:person][:mother][:current_village]).id
        end
        if person_address.save
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
        end
    end

    if ["mother_address_home_district","mother_address_home_ta", "mother_address_home_village"].include?(params[:field])
        person_mother = Person.find(params[:id]).mother
        person_address = PersonAddress.find_by_person_id(person_mother.id)

        if params[:person][:mother][:home_district].present?
          person_address.home_district  = Location.find_by_name(params[:person][:mother][:home_district]).id
        end
        if params[:person][:mother][:home_ta].present?
          person_address.home_ta = Location.find_by_name(params[:person][:mother][:home_ta]).id
        end
        if params[:person][:mother][:home_village].present?
          person_address.home_village = Location.find_by_name(params[:person][:mother][:home_village]).id
        end
        if person_address.save
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
        end
    end

    if ["father_last_name","father_first_name","father_middle_name", "father_id_number","mother_birth_date", "person_surname"].include?(params[:field])
          person = Person.find(params[:id])
          person_father = person.father

          if person_father.blank?
              father   = Lib.new_father(person, params, 'Father')
              redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
          end

          person_father_name = PersonName.find_by_person_id(person_father.id)
          if params[:person][:father][:first_name] != person_father_name.first_name  || params[:person][:father][:last_name] != person_father_name.last_name || params[:person][:father][:middle_name] != person_father_name.middle_name
            person_father_name.update_attributes(voided: true, void_reason: 'General edit')
            person_father_name = PersonName.create(person_id: person_father.id,
                  first_name: params[:person][:father][:first_name],
                  middle_name: params[:person][:father][:middle_name],
                  last_name: params[:person][:father][:last_name])
          end
          
          if params[:person][:father][:id_number].present?
              identifier_type = PersonIdentifierType.find_by_name("National ID Number").id
              
              father_identifier = PersonIdentifier.where(person_id: person_father.id, person_identifier_type_id: identifier_type).last
              
              if father_identifier.present?
                 father_identifier.update_attributes(value: params[:person][:mother][:id_number])
              else
                PersonIdentifier.create(
                          person_id: mother_person.person_id,
                          person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
                          value: params[:person][:father][:id_number]
                  )
              end
          end

          if params[:person][:father][:birthdate].present?
              person_father.birthdate = params[:person][:father][:birthdate].to_date.to_s
              person_father.save
          end
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
    end

    if ["father_address_current_district","father_address_current_ta","father_address_current_village","father_citizenship"].include?(params[:field])
        person_father = Person.find(params[:id]).father
        person_address = PersonAddress.find_by_person_id(person_father.id)
        if params[:person][:father][:citizenship].present?
          person_address.citizenship = Location.find_by_country(params[:person][:father][:citizenship]).id
        end
        if params[:person][:father][:residential_country].present?
          person_address.residential_country = Location.find_by_name(params[:person][:father][:residential_country]).id
        end
        if params[:person][:father][:current_district].present?
          person_address.current_district  = Location.find_by_name(params[:person][:father][:current_district]).id
        end
        if params[:person][:father][:current_ta].present?
          person_address.current_ta = Location.find_by_name(params[:person][:father][:current_ta]).id
        end
        if params[:person][:father][:current_village].present?
          person_address.current_village = Location.find_by_name(params[:person][:father][:current_village]).id
        end
        if person_address.save
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
        end
    end

    if ["father_address_home_district","father_address_home_ta","father_address_home_village"].include?(params[:field])
        person_father = Person.find(params[:id]).father
        person_address = PersonAddress.find_by_person_id(person_father.id)
        if params[:person][:father][:home_district].present?
          person_address.home_district  = Location.find_by_name(params[:person][:father][:home_district]).id
        end
        if params[:person][:father][:home_ta].present?
          person_address.home_ta = Location.find_by_name(params[:person][:father][:home_ta]).id
        end
        if params[:person][:father][:home_village].present?
          person_address.home_village = Location.find_by_name(params[:person][:father][:home_village]).id
        end
        if person_address.save
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
        end      
    end

    if ["informant_last_name","informant_first_name","informant_middle_name", "informant_id_number", "informant_relationship"].include?(params[:field])
          person_informant = Person.find(params[:id]).informant
          person_informant_name = PersonName.find_by_person_id(person_informant.id)
          if params[:person][:informant][:first_name] != person_informant_name.first_name  || params[:person][:informant][:last_name] != person_informant_name.last_name || params[:person][:informant][:middle_name] != person_informant_name.middle_name
            person_informant_name.update_attributes(voided: true, void_reason: 'General edit')
            person_informant_name = PersonName.create(person_id: person_informant.id,
                  first_name: params[:person][:informant][:first_name],
                  middle_name: params[:person][:informant][:middle_name],
                  last_name: params[:person][:informant][:last_name])
          end
          
          if params[:person][:informant][:id_number].present?
              identifier_type = PersonIdentifierType.find_by_name("National ID Number").id
              
              informant_identifier = PersonIdentifier.where(person_id: person_father.id, person_identifier_type_id: identifier_type).last
              
              if father_identifier.present?
                 father_identifier.update_attributes(value: params[:person][:informant][:id_number])
              else
                PersonIdentifier.create(
                          person_id: mother_person.person_id,
                          person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
                          value: params[:person][:informant][:id_number]
                  )
              end
          end
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
    end

    if ["informant_address_home_district","informant_address_home_ta","informant_address_home_village", "informant_address"].include?(params[:field])
      person_informant = Person.find(params[:id]).informant
      person_address = PersonAddress.find_by_person_id(person_informant.id)      
      if params[:person][:informant][:current_district].present?
          person_address.current_district  = Location.find_by_name(params[:person][:informant][:current_district]).id
      end
      if params[:person][:informant][:current_ta].present?
          person_address.current_ta = Location.find_by_name(params[:person][:informant][:current_ta]).id
      end
      if params[:person][:informant][:current_village].present?
          person_address.current_village = Location.find_by_name(params[:person][:informant][:current_village]).id
      end
      if params[:person][:informant][:addressline1].present?
          person_address.address_line_1 = params[:person][:informant][:addressline1]
      end
      if params[:person][:informant][:addressline2].present?
         person_address.address_line_2 = params[:person][:informant][:addressline2]
      end
      if person_address.save
          redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
      end  

    end
   
    if ["informant_cell_phone_number","birth_details_form_signed","child_acknowledgement_of_receipt_date"].include?(params[:field])
      
        person_informant = Person.find(params[:id]).informant
        if params[:person][:informant][:phone_number].present?
            informant_number = PersonAttribute.find_by_person_id(person_informant.id)
            if informant_number.blank?
                  PersonAttribute.create(
                      :person_id                => person_informant.id,
                      :person_attribute_type_id => PersonAttributeType.where(name: 'cell phone number').last.id,
                      :value                    => params[:person][:informant][:phone_number],
                      :voided                   => 0
                  )
            else
                informant_number.voided = 0
                informant_number.save
                PersonAttribute.create(
                      :person_id                => person_informant.id,
                      :person_attribute_type_id => PersonAttributeType.where(name: 'cell phone number').last.id,
                      :value                    => params[:person][:informant][:phone_number],
                      :voided                   => 0
                  )

            end
        end

        birth_details = PersonBirthDetail.where(person_id: params[:id]).last
        if params[:person][:form_signed].present?
          birth_details.form_signed = (params[:person][:form_signed] == "Yes" ? 1 : 0)
          birth_details.save
        end
        if params[:person][:acknowledgement_of_receipt_date].present?
          birth_details.acknowledgement_of_receipt_date = params[:person][:acknowledgement_of_receipt_date].to_date.to_s
          birth_details.save
        end
        redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
    end

    if ["national_id"].include?(params[:field])
        existing = PersonIdentifier.where("person_id = #{params[:id]} AND
                             person_identifier_type_id = #{PersonIdentifierType.find_by_name('National ID Number').id} AND voided = 0")
        if existing.present?
            existing.each do |e|
              e.voided = 1
              e.save
            end
        end

        PersonIdentifier.create(
                person_id: params[:id],
                person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
                value: params[:person][:national_id].upcase
        )

        redirect_to "/person/#{params[:id]}/edit?next_path=/view_cases" and return
    end

  end   

  def person_for_elastic_search(core_person,params)
      person = {}
      person["id"] = core_person.person_id
      person["first_name"]= params[:person][:first_name]
      person["last_name"] =  params[:person][:last_name]
      person["middle_name"] = params[:person][:middle_name]
      person["gender"] = params[:person][:gender]
      person["birthdate"]= params[:person][:birthdate].to_date.strftime('%Y-%m-%d')
      person["birthdate_estimated"] = params[:person][:birthdate_estimated]

      if is_twin_or_triplet(params[:person][:type_of_birth].to_s) && params[:person][:prev_child_id].present?
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

         person["mother_home_district"] = Location.find(mother.addresses.last.home_district).name rescue nil
         person["mother_home_ta"] = Location.find(mother.addresses.last.home_ta).name rescue nil
         person["mother_home_village"] = Location.find(mother.addresses.last.home_village).name rescue nil

         person["mother_current_district"] = Location.find(mother.addresses.last.current_district).name rescue nil
         person["mother_current_ta"] = Location.find(mother.addresses.last.current_ta).name rescue nil
         person["mother_current_village"] = Location.find(mother.addresses.last.current_village).name rescue nil

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

         person["father_home_district"] = Location.find(father.addresses.last.home_district).name rescue nil
         person["father_home_ta"] = Location.find(father.addresses.last.home_ta).name rescue nil
         person["father_home_village"] = Location.find(father.addresses.last.home_village).name rescue nil

         person["father_current_district"] = Location.find(father.addresses.last.current_district).name rescue nil
         person["father_current_ta"] = Location.find(father.addresses.last.current_ta).name rescue nil
         person["father_current_village"] = Location.find(father.addresses.last.current_village).name rescue nil

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

        person["mother_home_district"] = params[:person][:mother][:home_district] rescue nil
        person["mother_home_ta"] = params[:person][:mother][:home_ta] rescue nil
        person["mother_home_village"] = params[:person][:mother][:home_village] rescue nil
         
        person["mother_current_district"] = params[:person][:mother][:current_district] rescue nil
        person["mother_current_ta"] = params[:person][:mother][:current_ta] rescue nil
        person["mother_current_village"] = params[:person][:mother][:current_village] rescue nil

        person["father_first_name"]= params[:person][:father][:first_name] rescue nil
        person["father_last_name"] =  params[:person][:father][:last_name] rescue nil
        person["father_middle_name"] = params[:person][:father][:middle_name] rescue nil

        person["father_home_district"] = params[:person][:father][:home_district] rescue nil
        person["father_home_ta"] = params[:person][:father][:home_ta] rescue nil
        person["father_home_village"] = params[:person][:father][:home_village] rescue nil
         
        person["father_current_district"] = params[:person][:father][:current_district] rescue nil
        person["father_current_ta"] = params[:person][:father][:current_ta] rescue nil
        person["father_current_village"] = params[:person][:father][:current_village] rescue nil

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
                      "middle_name" => (psimilararams[:middle_name] rescue nil),
                      "gender" => params[:gender],
                      "district" => params[:birth_district],
                      "birthdate"=> birthdate.to_date.strftime('%Y-%m-%d'),
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
      dupliates = SimpleElasticSearch.query_duplicate_coded(person,99.4)
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
      data = PersonName.find_by_sql(" SELECT last_name FROM person_name WHERE last_name LIKE '#{params[:search]}%' ORDER BY last_name LIMIT 10").map(&:last_name)
      if data.present?
        render text: data.reject{|n| n == '@@@@@'}.join("\n") and return
      else
        render text: "" and return
      end
    elsif params["first_name"]
      data = PersonName.find_by_sql(" SELECT first_name FROM person_name WHERE first_name LIKE '#{params[:search]}%' ORDER BY first_name LIMIT 10").map(&:first_name)
      if data.present?
        render text: data.reject{|n| n == '@@@@@'}.join("\n") and return
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
    data = []

    data = ['Malawi'] unless !params[:exclude].blank?  && params[:exclude].split("|").include?("Malawi")

    Location.where("LENGTH(name) > 0 AND country != 'Malawi' AND name LIKE (?) AND m.location_tag_id = ?", 
      "#{params[:search]}%", nationality_tag.id).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|

      if params[:exclude].present?
        next if params[:exclude].split("|").include?(l.name)
      end
      data << l.name
    end
    
    if data.present?
      render text: data.compact.uniq.join("\n") and return
    else
      render text: "" and return
    end
  end

  def get_district 

    cities = ["Blantyre City","Lilongwe City","Mzuzu City","Zomba City"]

    nationality_tag = LocationTag.where(name: 'District').first
    data = []
    Location.where("LENGTH(name) > 0 AND name LIKE (?) AND m.location_tag_id = ?",
      "#{params[:search]}%", nationality_tag.id).joins("INNER JOIN location_tag_map m
      ON location.location_id = m.location_id").order('name ASC').map do |l|
      if params[:exclude].present?
        next if params[:exclude].split("|").include?(l.name)
      end
      data << l.name
    end

    if data.present?
      data << "Other Country" if params[:include_other_country].to_s == "true"
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
    data << "Other" if params[:include_other].to_s == "true"
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
    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_incomplete_cases
    @states = ["DC-INCOMPLETE"]
    @section = "Incomplete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @targeturl = "/manage_cases"
    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_pending_cases
    @states = ["DC-PENDING","DC-INCOMPLETE"]
    @section = "Pending Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @targeturl = "/"
    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_rejected_cases
    @states = ["DC-REJECTED"]
    @section = "Rejected Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_hq_rejected_cases
    @states = ["HQ-REJECTED"]
    @section = "Rejected Cases at HQ"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def edit

    @targeturl = request.path

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

		if @mother_person.present?
        mother_birth_date = @mother_person.birthdate.present? && @mother_person.birthdate.to_date.strftime('%Y-%m-%d') =='1900-01-01' ? 'N/A':  @mother_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil
    else
        mother_birth_date = nil
    end

    if @father_person.present?
        father_birth_date = @father_person.birthdate.present? && @father_person.birthdate.to_date.strftime('%Y-%m-%d') =='1900-01-01' ? 'N/A':  						@father_person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil
    else
        father_birth_date = nil
    end

    @informant_person = @person.informant rescue nil
    @informant_address = @informant_person.addresses.last rescue nil
    @informant_name = @informant_person.person_names.last rescue nil

    @comments = PersonRecordStatus.where(" person_id = #{@person.id} AND COALESCE(comments, '') != '' ")
    days_gone = ((@birth_details.acknowledgement_of_receipt_date.to_date rescue Date.today) - @person.birthdate.to_date).to_i rescue 0
    @delayed =  days_gone > 42 ? "Yes" : "No"
    location = Location.find(SETTINGS['location_id'])
    facility_code = location.code

    birth_loc = Location.find(@birth_details.birth_location_id)
    birth_loc = nil if birth_loc.name == "Other"
    district_loc = Location.find(@birth_details.district_of_birth)

    other_place = nil
    district = nil
    ta       = nil
    village  = nil
    hospital = nil

    place = Location.find(@birth_details.place_of_birth).name
    if place == "Home"
      district = district_loc.name
      village = birth_loc.village rescue nil
      ta = birth_loc.ta rescue nil
      if village.blank? #Foreign Birth
        other_place = @birth_details.other_birth_location
      end
    elsif place == "Hospital"
      district = district_loc.name
      hospital = birth_loc.name rescue @birth_details.other_birth_location
    else
      district = district_loc.name
      other_place = @birth_details.other_birth_location
    end

    place_of_birth = "#{other_place}, #{village}, #{hospital}, #{ta}, #{district}".gsub(" ,", "").strip.gsub(/^,|^,\s+|,$|,\s+$/, "")

    @place_of_birth = @birth_details.other_birth_location if @place_of_birth.blank?

    @status = PersonRecordStatus.status(@person.id)

    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, [@status])
    informant_rel = (!@birth_details.informant_relationship_to_person.blank? ?
        @birth_details.informant_relationship_to_person : @birth_details.other_informant_relationship_to_person) rescue nil

    @record = {
        "Details of Child" => [
            {
                "Birth Entry Number" => "#{@birth_details.ben rescue nil}",
                "Birth Registration Number" => "#{@birth_details.brn  rescue nil}",
                ["National ID","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=national_id"] => (@person.id_number rescue '')
            },  
            {
                ["First Name","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_first_name"] => "#{@name.first_name rescue nil}",
                ["Other Name","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_middle_name"] => "#{@name.middle_name rescue nil}",
                ["Surname", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_surname"] => "#{@name.last_name rescue nil}"
            },
            {
                ["Date of birth", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_birthdate"] => "#{@person.birthdate.to_date.strftime('%d/%b/%Y') rescue nil}",
                ["Sex", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=child_gender"] => "#{(@person.gender == 'F' ? 'Female' : 'Male')}",
                ["Place of birth","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_place_of_birth"] => place
            },
            {
                ["Name of Hospital","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_hospital_of_birth"] =>  hospital,
                ["Other Details","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_details_other_details"] => other_place,
            },
            {
                ["District/State", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_location_district"] => district,
                ["T/A", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_location_ta"] => ta,
                ["Village","/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=birth_location_village"] => village
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
                "Record Complete?" => (@birth_details.record_complete? rescue false) ? "Yes" : "No"
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
                ["Date of birth", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=mother_birth_date"] => "#{mother_birth_date}",
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
                ["Date of birth", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_birthdate"] => "#{father_birth_date}",
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
                ["Home Address, Village/Town", "/update_person?id=#{@person.person_id}&next_path=#{@targeturl}&field=father_address_home_village"] => "#{loc(@father_address.home_village, 'Village') rescue nil}"
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
      "Place of Birth" => place_of_birth,
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

  def do_dispatch_these
    
    
    query = "SELECT person.person_id,person_birth_details.district_id_number as BEN, 
                  CONCAT(first_name,' ', last_name) as Name , gender as Sex, 
                  DATE_FORMAT(birthdate,'%Y-%m-%d') as DoB, place_of_birth.name as PoB, 
                  CONCAT(birth_location.name, ',', district_of_birth.name) as Location, 
                  DATE_FORMAT(person_birth_details.date_registered,'%Y-%m-%d') as DateOfReg, 
                  CONCAT( InformantFirstName, ' ', InformantLastName) as NameOfInformant,
                  person_addresses_id, 
                  district as DistrictOfInformant, ta as TraditionalAuthorityOfInformant, 
                  village as VillageOfInformant FROM 
                      (SELECT * FROM person 
                          WHERE person_id IN('#{params[:person_ids].join("','")}')) person 
                            INNER JOIN person_name INNER JOIN person_birth_details INNER 
                            JOIN location place_of_birth INNER JOIN location district_of_birth 
                            INNER JOIN location birth_location 
                            INNER JOIN (SELECT person_id FROM person_record_statuses 
                                WHERE status_id IN (SELECT status_id FROM `statuses` 
                                                        WHERE `name` = 'DC-PRINTED' OR `name` = 'HQ-PRINTED')) status 
                            INNER JOIN (SELECT * FROM (SElECT person_a, person_b, person_name.first_name as InformantFirstName, person_name.last_name as InformantLastName
                                        FROM person_relationship INNER JOIN person_name 
                                              ON  person_relationship.person_b = person_name.person_id WHERE person_relationship_type_id = '4' AND 
                                              person_a IN('#{params[:person_ids].join("','")}')) informant
                    LEFT JOIN
                    (SELECT d.person_addresses_id, d.person_id, d.name as district, ta, village FROM 
                    (SELECT person_addresses_id, person_id, district.name 
                    FROM person_addresses INNER JOIN location district 
                      ON person_addresses.current_district = district.location_id 
                    WHERE person_id IN(SELECT person_b FROM person_relationship WHERE person_relationship_type_id = '4' AND 
                      person_a IN('#{params[:person_ids].join("','")}'))) d
                    LEFT JOIN
                          (SELECT t.person_addresses_id, t.person_id, t.name as ta , v.name as village FROM
                      (SELECT person_addresses_id, person_id, ta.name 
                      FROM person_addresses INNER JOIN location ta 
                        ON person_addresses.current_ta = ta.location_id 
                      WHERE person_id IN(SELECT person_b FROM person_relationship WHERE person_relationship_type_id = '4' AND 
                        person_a IN('#{params[:person_ids].join("','")}'))) t
                  
                      LEFT JOIN
                      (SELECT person_addresses_id, person_id, village.name 
                      FROM person_addresses INNER JOIN location village
                        ON person_addresses.current_village = village.location_id 
                      WHERE person_id IN(SELECT person_b FROM person_relationship WHERE person_relationship_type_id = '4' AND 
                        person_a IN('#{params[:person_ids].join("','")}'))) v
                      ON t.person_addresses_id = v.person_addresses_id) ta_village
                    ON d.person_addresses_id = ta_village.person_addresses_id) address
                      ON informant.person_b = address.person_id) informant_address 
                    ON person.person_id = person_name.person_id AND person.person_id = person_birth_details.person_id 
                    AND person_birth_details.person_id = status.person_id AND informant_address.person_a = person.person_id 
                    AND person_birth_details.place_of_birth = place_of_birth.location_id 
                    AND person_birth_details.district_of_birth = district_of_birth.location_id 
                    AND person_birth_details.birth_location_id = birth_location.location_id 
                    ORDER BY district, ta, village, person_name.last_name, person_name.first_name LIMIT 20000"
    #raise query.to_s
    @data = ActiveRecord::Base.connection.select_all(query).as_json

    if params[:dispatch_action] == "download"
      if params[:file_type] == "CSV"
        dispatch_file = "#{Rails.root}/tmp/Dispatch.csv"
        write_csv(dispatch_file,"header", [	"Name",	"Sex", "Date of Birth", "Place of Birth", "Location", "Name of Mother", "Name of Informant","District of Infomant", "Traditional Authority of Infomant", "Village of Informant","Collected By","ID Number(TYPE - NUMBER)","Phone Number","Signature", "Date Signed"])
        @data.each_with_index do |row,i|
         
          village = row["VillageOfInformant"]
          if row["VillageOfInformant"] =="Other"
              address = PersonAddress.find(row["person_addresses_id"])
              village = address.current_village_other
          end 
          ta = row["TraditionalAuthorityOfInformant"]
          if row["TraditionalAuthorityOfInformant"] =="Other"
            address = PersonAddress.find(row["person_addresses_id"])
            ta = address.current_ta_other
          end

          mother_query = "SElECT person_a, person_b, person_name.first_name as MotherFirstName, person_name.last_name as MotherLastName
                      FROM person_relationship INNER JOIN person_name ON  person_relationship.person_b = person_name.person_id 
                      WHERE person_relationship_type_id = '5' AND  person_a = '#{row['person_id']}'"
        
          mother = ActiveRecord::Base.connection.select_all(mother_query ).as_json.first
          
          write_csv(dispatch_file,"content", [row["Name"],	row["Sex"], row["DoB"], row["PoB"], row["Location"], "#{mother['MotherFirstName']} #{mother['MotherLastName']}", row["NameOfInformant"], row["DistrictOfInformant"], ta, village,"","","","", ""])
          
          log = "#{Rails.root}/tmp/dispatch-#{Dir["#{Rails.root}/tmp/*"].count + 1}.txt"
          `echo "\n" >> #{log}`
          `echo "#{row["person_id"]}" >> #{log}`
  
          #PersonRecordStatus.new_record_state(row["person_id"], "HQ-DISPATCHED", "DC-DISPATCHED")
        end
        send_file(dispatch_file, :filename => "Dispatch #{Time.now}.csv", :disposition => 'inline', :type => "text/csv")
      elsif params[:file_type] == "PDF"
        json_file = "#{Rails.root}/tmp/Dispatch.json"
        File.open(json_file,"w") do |f|
          f.write(@data.to_json)
        end
        dispatch_file = "#{Rails.root}/tmp/Dispatch.pdf"
        dispatch_url = "wkhtmltopdf  -O landscape --zoom 0.75 #{SETTINGS["protocol"]}://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/dispatch_preview?user_id=#{User.current.id} #{dispatch_file}\n"
        Kernel.system dispatch_url
        send_file(dispatch_file, :filename => "Dispatch #{Time.now}.pdf", :disposition => 'inline', type: 'application/pdf')
        #render :text => @data.to_json
      end
    else

    end
  end


  def dispatch_preview
    @district =  Location.find(SETTINGS['location_id'])
    User.current = User.find(params[:user_id])
    @data =  JSON.parse(File.read("#{Rails.root}/tmp/Dispatch.json"))
    render :layout => false
  end

  def view_printed_cases
    #raise params[:statuses].inspect
    @district =  Location.current_district
    if params[:loc] == "hq"
      @states = ["HQ-PRINTED"]
      @section = "Cases Printed at HQ"
    elsif params[:loc] == "dc"
      @states = ["DC-PRINTED"]
      @section = "Cases Printed at DC"
    else
      @states = ["HQ-PRINTED","DC-PRINTED"]
      @section = "All Printed Cases"
    end

    @type_stats = PersonRecordStatus.type_stats(@states, params[:had], params[:had_by])
    facility_tag_id = LocationTag.where(name: "Health Facility").first.id
    district_tag_id = LocationTag.where(name: "District").first.id
  
    printable_statuses = Status.where("name IN ('#{@states.join("','")}')").map(&:status_id)
  
=begin
    @facilities = ActiveRecord::Base.connection.select_all("
          SELECT d.location_created_at, l.name FROM person_birth_details d
            INNER JOIN location l ON l.location_id = d.location_created_at
            INNER JOIN location_tag_map m ON m.location_id = l.location_id AND m.location_tag_id = #{facility_tag_id}
          GROUP BY location_created_at
            "
    ).collect{|c| [c['location_created_at'], c['name']]}
=end
  
    @facilities = ActiveRecord::Base.connection.select_all("
          SELECT d.birth_location_id, l.name FROM person_birth_details d
            INNER JOIN location l ON l.location_id = d.birth_location_id
            INNER JOIN location_tag_map m ON m.location_id = l.location_id AND m.location_tag_id = #{facility_tag_id}
            WHERE l.parent_location = #{SETTINGS['location_id']}
            "
    ).collect{|c| [c['birth_location_id'], c['name']]}.uniq
  
    @districts = ActiveRecord::Base.connection.select_all("
          SELECT l.location_id, l.name FROM location_tag_map m
            INNER JOIN location l ON l.location_id = m.location_id
            WHERE m.location_tag_id = #{district_tag_id}
          GROUP BY l.location_id
            "
    ).collect{|c| [c['location_id'], c['name']]}
  
    cur_loc_id = SETTINGS['location_id']
    cur_loc_name = Location.find(cur_loc_id).name
  
    @facilities << [cur_loc_id, "#{cur_loc_name} (ADR)"]
  
    params[:statuses] = [] if params[:statuses].blank?
    session[:list_url] = request.referrer
    @states = params[:statuses] if @states.blank?
    @states = ["HQ-PRINTED","DC-PRINTED"] if @states.blank?
  
    @icoFolder = folder
    @targeturl = "/"
  
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states) rescue []
    types = []
  
    @birth_type = params[:birth_type]
  
    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?
    search_category = ''
  
    if !params[:category].blank?
  
      if params[:category] == 'continuous'
        search_category = " AND (pbd.source_id IS NULL OR LENGTH(pbd.source_id) >  19)  "
      elsif params[:category] == 'mass_data'
        search_category = " AND (pbd.source_id IS NOT NULL AND LENGTH(pbd.source_id) <  20 ) "
      elsif params[:category] == "community_data"
        search_category = " AND (pbd.source_id IS NOT NULL AND pbd.source_id LIKE '%#%' ) "
      else
        search_category = ""
      end
  
      session[:category] = params[:category]
    end
  
    if !params[:start].blank?
  
      loc_query = " "
      locations = []
  
      if params[:district] == "All"
        session[:district] = ""
      end
  
      if params[:district].present? && params[:district] != "All"
        session[:district] = params[:district]
  
        locations = [params[:district]]
  
        facility_tag_id = LocationTag.where(name: 'Health Facility').first.id rescue [-1]
        (Location.find_by_sql("SELECT l.location_id FROM location l
                              INNER JOIN location_tag_map m ON l.location_id = m.location_id AND m.location_tag_id = #{facility_tag_id}
                            WHERE l.parent_location = #{params[:district]}") || []).each {|l|
          locations << l.location_id
        }
        loc_query = " AND pbd.location_created_at IN (#{locations.join(', ')}) "
      end
  
      facility_filter = ""
      if !params[:facility_id].blank? && params[:facility_id] != "All"
        session[:facility_id] = params[:facility_id]
        facility_filter = " AND pbd.birth_location_id = #{params[:facility_id]} "
      else
        session[:facility_id] = ""
      end
  
      state_ids = @states.collect{|s| Status.find_by_name(s).id} + [-1]
      types=['Normal', 'Abandoned', 'Adopted', 'Orphaned'] if params[:type] == 'All'
      types=['Abandoned', 'Adopted', 'Orphaned'] if params[:type] == 'All Special Cases'
      types=[params[:type]] if types.blank?
  
      person_reg_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]
  
      had_query = ' '
      if !params['had'].blank?
        #probe user who made previous change
        user_hook = ""
        if params['had_by'].present?
  
          had_by_users =  UserRole.where(role_id: Role.where(role: params['had_by']).last.id).map(&:user_id) rescue [-1]
          had_by_users =  [-1] if had_by_users.blank?
          user_hook = " AND prev_s.creator IN (#{had_by_users.join(', ')}) " if had_by_users.length > 0
        end
  
        prev_states = params['had'].split('|')
        prev_state_ids = prev_states.collect{|sn| Status.where(name: sn).last.id  rescue -1 }
        had_query = " INNER JOIN person_record_statuses prev_s ON prev_s.person_id = prs.person_id #{user_hook}
               AND prev_s.status_id IN (#{prev_state_ids.join(', ')})"
      end
  
      informant_join_query = "  "
      if !params[:informant_village].blank? && !params[:informant_ta].blank? && !params[:informant_district].blank?
  
        district_id          = Location.locate_id_by_tag(params[:informant_district], "District")
        ta_id                = Location.locate_id(params[:informant_ta], "Traditional Authority", district_id)
        village_id           = Location.locate_id(params[:informant_village], "Village", ta_id)
  
        village_filter_query = " " #" AND pbd.location_created_at  = #{village_id}"
  
        info_type_id         = PersonRelationType.where(name: "Informant").first.id
        informant_join_query = "INNER JOIN person_relationship p_rel ON p_rel.person_a = person.person_id
                                  AND p_rel.person_relationship_type_id = #{info_type_id}
                                INNER JOIN person_addresses info_a ON info_a.person_id = p_rel.person_b
                                  AND ((info_a.current_district = #{district_id}
                                        AND info_a.current_ta = #{ta_id}
                                        AND info_a.current_village  = #{village_id})
                                          OR
                                        (pbd.location_created_at  = #{village_id}))
                                "
  
      end
  
      #faulty_ids = [-1] + PersonRecordStatus.find_by_sql("SELECT prs.person_record_status_id FROM person_record_statuses prs
       #                                           LEFT JOIN person_record_statuses prs2 ON prs.person_id = prs2.person_id AND prs.voided = 0 AND prs2.voided = 0
         #                                         WHERE prs.created_at < prs2.created_at;").map(&:person_record_status_id)
  
      d = Person.order(" pbd.district_id_number, pbd.national_serial_number, n.first_name, n.last_name, cp.created_at ")
      .joins(" INNER JOIN core_person cp ON person.person_id = cp.person_id
                INNER JOIN person_name n ON person.person_id = n.person_id
                INNER JOIN person_record_statuses prs ON person.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
                #{had_query}
                INNER JOIN person_birth_details pbd ON person.person_id = pbd.person_id
                #{informant_join_query}
      ")
      .where(" prs.status_id IN (#{state_ids.join(', ')}) AND n.voided = 0
                AND prs.created_at = (SELECT MAX(created_at) FROM person_record_statuses prs2 WHERE prs2.person_id = person.person_id)
                #{village_filter_query} AND pbd.district_id_number IS NOT NULL
                AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')}) #{loc_query} #{facility_filter} 
                AND concat_ws('_', pbd.national_serial_number, pbd.district_id_number, n.first_name, n.last_name, n.middle_name,
                person.birthdate, person.gender) REGEXP \"#{search_val}\"  #{search_category} ")
  
      total = d.select(" count(*) c ")[0]['c'] rescue 0
      page = (params[:start].to_i / params[:length].to_i) + 1
  
      data = d.group(" prs.person_id ")
  
      data = data.select(" n.*, prs.status_id, pbd.district_id_number AS ben, person.gender, person.birthdate, pbd.national_serial_number AS brn")
      data = data.page(page)
      .per_page(params[:length].to_i)
  
      @records = []
      nid_data = []
      data.each do |p|
        mother = PersonService.mother(p.person_id)
        father = PersonService.father(p.person_id)
        details = PersonBirthDetail.find_by_person_id(p.person_id)
  
        p['first_name'] = '' if p['first_name'].present? && p['first_name'].match('@')
        p['last_name'] = '' if p['last_name'].present? && p['last_name'].match('@')
        p['middle_name'] = '' if p['middle_name'].present? && p['middle_name'].match('@')
  
        name          = ("#{p['first_name']} #{p['middle_name']} #{p['last_name']}")
        mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
        father_name   = ("#{father.first_name rescue 'N/A'} #{father.middle_name rescue ''} #{father.last_name rescue ''}")
  
        arr = [
            p.ben
            ]
  
        national_id = p.id_number rescue ""
        arr  << (national_id)
  
        arr = arr + [name,
                     p.birthdate.strftime('%d/%b/%Y'),
                     p.gender,
                     mother_name,
                     father_name,
                     Status.find(p.status_id).name.sub("HQ-CAN-PRINT", "CAN-PRINT"),
                     p.person_id
        ]
  
        @records << arr
      end 
  
      render :text => {
          "draw" => params[:draw].to_i,
          "recordsTotal" => total,
          "recordsFiltered" => total,
          "data" => @records}.to_json and return
    end
  
    @online = false
    require 'open3'
    host, port = SETTINGS['sync_host'].split(":")
    a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
    if b.scan(/succeeded/).length > 0
      @online = true
    end
  
    render :template => "/dc/records", layout: "bootstrap_data_table"
  end
=begin
  def view_printed_cases

    @district =  Location.current_district
    if params[:loc] == "hq"
      @states = ["HQ-PRINTED"]
      @section = "Cases Printed at HQ"
    elsif params[:loc] == "dc"
      @states = ["DC-PRINTED"]
      @section = "Cases Printed at DC"
    else
      @states = ["HQ-PRINTED","DC-PRINTED"]
      @section = "All Printed Cases"
    end

    if SETTINGS["enable_decentralised_printing"].to_s == "true"
      @targeturl = "/printed_cases"
    else
      @targeturl = "/manage_cases"
    end

    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    @dispatch = true
    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end
=end
  def view_voided_cases
    @states = ["DC-VOIDED"]
    @section = "Voided Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_approved_cases
    @states = Status.where("name like 'HQ-%' ").map(&:name) - ['HQ-REJECTED', 'HQ-VOIDED', 'HQ-PRINTED', 'HQ-DISPATCHED']
    @section = "Approved Cases"
    @display_ben = true
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

   # @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_dispatched_cases
    @states = ["HQ-DISPATCHED"]
    @section = "Voided Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def lost_and_damaged_cases
    @states = ["DC-LOST", 'DC-DAMAGED']
    @section = "Lost/Damaged Cases"
    @display_ben = true
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end


  def ammendment_cases
    @states = ['DC-AMEND']
    @section = "Ammendments"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def rejected_ammendment_cases
    @states = ['DC-AMEND-REJECTED','DC-LOST-REJECTED','DC-DAMAGED-REJECTED']
    @section = "Rejected Amendments"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    #@records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def ammend_case
    @person = Person.find(params[:id])
    @status = PersonRecordStatus.status(@person.id)

    @prev_details = {}
    @birth_details = PersonBirthDetail.where(person_id: params[:id]).last

    @name = @person.person_names.last

    @person_prev_values = {}
    name_fields = ['person_name', "gender","birthdate",
                   "place_of_birth", "mother_name", "father_name",
                   "mother_citizenship", "father_citizenship"]

    name_fields.each do |field|
        trail = AuditTrail.where(person_id: params[:id], field: field).order('created_at').last
        if trail.present?
            @person_prev_values[field] = trail.previous_value
        end
    end

    @address = @person.addresses.last

    @mother_person = @person.mother
    @mother_address = @mother_person.addresses.last
    @mother_name = @mother_person.person_names.last rescue nil
    @mother_nationality = Location.find(@mother_address.citizenship).country

    @father_person = @person.father
    @father_name = @father_person.person_names.last rescue nil
    @father_address = @father_person.addresses.last rescue nil
    @father_nationality = Location.find(@father_address.citizenship).country rescue nil

    @targeturl = session[:list_url] 
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
    user_id = User.current.id
    
    if fields.include? "Name"
      person      = Person.find(params[:id])
      person_name = PersonName.find_by_person_id(params[:id])
      AuditTrail.create_ammendment_trail(params[:id], "person_name", person.name, user_id)

      person_name.update_attributes(voided: true, void_reason: 'Amendment edited')
      person_name = PersonName.create(person_id: params[:id],
            first_name: params[:person][:first_name],
            last_name: params[:person][:last_name],middle_name: params[:person][:middle_name])
    end
    if fields.include? "Date of birth"
        person = Person.find(params[:id])
        AuditTrail.create_ammendment_trail(params[:id], "birthdate", person.birthdate, user_id)

        person.update_attributes(birthdate: params[:person][:birthdate], birthdate_estimated: (params[:person][:birthdate_estimated]? params[:person][:birthdate_estimated] : 0))
    end
    if fields.include? "Sex"
       person = Person.find(params[:id])

       gender_n = {"F" => "Female", "M" => "Male"}[person.gender]
       gender_n = person.gender if gender_n.blank?

       AuditTrail.create_ammendment_trail(params[:id], "gender", gender_n, user_id)

       gender = params[:person][:gender]  == "Female" ? 'F' : 'M'
       person.update_attributes(gender: gender)
    end
    if fields.include? "Place of birth"
        person_birth_details = PersonBirthDetail.where(person_id: params[:id]).last
        place_of_birth = params[:person][:place_of_birth]
        place_of_birth_id = Location.locate_id_by_tag(params[:person][:place_of_birth], 'Place of Birth')

        AuditTrail.create_ammendment_trail(params[:id], "place_of_birth", person_birth_details.birthplace, user_id)

        case place_of_birth
        when "Home"
          district_id = Location.locate_id_by_tag(params[:person][:birth_district], 'District')
          ta_id = Location.locate_id(params[:person][:birth_ta], 'Traditional Authority', district_id)
          village_id = Location.locate_id(params[:person][:birth_village], 'Village', ta_id)
          location_id = [village_id, ta_id, district_id].compact.first

          person_birth_details.place_of_birth = place_of_birth_id
          person_birth_details.district_of_birth = district_id
          person_birth_details.birth_location_id = location_id
          person_birth_details.other_birth_location = nil
          person_birth_details.save
        when "Hospital"
           map =  {'Mzuzu City' => 'Mzimba',
                'Lilongwe City' => 'Lilongwe',
                'Zomba City' => 'Zomba',
                'Blantyre City' => 'Blantyre'}

          params[:person][:birth_district] = map[params[:person][:birth_district]] if params[:person][:birth_district].match(/City$/)

          district_id = Location.locate_id_by_tag(params[:person][:birth_district], 'District')
          location_id = Location.locate_id(params[:person][:hospital_of_birth], 'Health Facility', district_id)

          location_id = [location_id, district_id].compact.first

          person_birth_details.place_of_birth = place_of_birth_id
          person_birth_details.district_of_birth = district_id
          person_birth_details.birth_location_id = location_id
          person_birth_details.other_birth_location = nil
          person_birth_details.save
        when "Other"
          district_id = Location.locate_id_by_tag(params[:person][:birth_district], 'District')
          location_id = Location.where(name: 'Other').last.id #Location.locate_id_by_tag(person[:birth_district], 'District')
          other_place_of_birth = params[:other_birth_place_details]

          person_birth_details.place_of_birth = place_of_birth_id
          person_birth_details.district_of_birth = district_id
          person_birth_details.birth_location_id = location_id
          person_birth_details.other_birth_location = other_place_of_birth
          person_birth_details.save
        end
    end
    if fields.include? "Name of mother"
        person = Person.find(params[:id])
        person_mother_name = person.mother.person_names.last

        AuditTrail.create_ammendment_trail(params[:id], "mother_name", (person.mother.name rescue nil), user_id)

        person_mother_name.update_attributes(voided: true, void_reason: 'Amendment edited')
        person_mother_name = PersonName.create(person_id: person.mother.id,
            first_name: params[:person][:mother][:first_name],
            last_name: params[:person][:mother][:last_name],
            middle_name: params[:person][:mother][:middle_name])
    end
    if fields.include? "Name of father"
        person = Person.find(params[:id])
        @father_person = person.father

        if @father_person.present?
          person_father_name = person.father.person_names.last

          AuditTrail.create_ammendment_trail(params[:id], "father_name", (person.father.name rescue nil), user_id)

          if person_father_name.present?
            person_father_name.update_attributes(voided: true, void_reason: 'Amendment edited')
          end
        else
            AuditTrail.create_ammendment_trail(params[:id], "father_name", "", user_id)

            core_person = CorePerson.create(
                :person_type_id     => PersonType.where(name: 'Father').last.id,
            )

            @father_person = Person.create(
                :person_id          => core_person.id,
                :gender             => 'M',
                :birthdate          => (params[:person][:father][:birthdate].blank? ? "1900-01-01" : params[:person][:father][:birthdate].to_date),
                :birthdate_estimated => (params[:person][:father][:birthdate].blank? ? 1 : 0)
            )
        end


        person_father_name = PersonName.create(person_id: @father_person.id,
              first_name: params[:person][:father][:first_name],
              last_name: params[:person][:father][:last_name],
              middle_name: params[:person][:father][:middle_name])

        PersonNameCode.create(person_name_id: person_father_name.person_name_id,
              first_name_code: params[:person][:father][:first_name].soundex,
              last_name_code: params[:person][:father][:last_name].soundex,
              middle_name_code: params[:person][:father][:middle_name].soundex)

        PersonRelationship.create(
                person_a: person.id, person_b: @father_person.person_id,
                person_relationship_type_id: PersonRelationType.where(name: 'Father').last.id
        )
    end

    if fields.include? "Nationality of Mother"
        person = Person.find(params[:id])
        @mother_person = person.mother
        location = Location.where(country: params[:person][:mother][:citizenship]).first
        @mother_address = @mother_person.addresses.last

        m_c = Location.find(@mother_address.citizenship).country rescue nil
        AuditTrail.create_ammendment_trail(params[:id], "mother_citizenship", m_c, user_id)

        @mother_address.citizenship = location.id
        @mother_address.save
    end

    if fields.include? "Nationality of Father"
        person = Person.find(params[:id])
        @father_person = person.father
        location = Location.where(country: params[:person][:father][:citizenship]).first

        @father_address = @father_person.addresses.last

        if @father_address.present?
            f_c = Location.find(@father_address.citizenship).country rescue nil
            AuditTrail.create_ammendment_trail(params[:id], "father_citizenship", f_c , user_id)

            @father_address.citizenship = location.id
            @father_address.save
        else
            @father_address = PersonAddress.create(
                person_id: @father_person.person_id,
                citizenship: location.id,
                residential_country: location.id

            )


        end
        
    end
    redirect_to "/person/ammend_case?id=#{params[:id]}&next_path=#{params[:next_path]}" 
  end

  def amendiment_comment
      render :layout => "touch"
  end
  def reprint_case
    @section = "Re-pring case"
    render :layout =>"touch"
  end

  def do_amend
    PersonRecordStatus.new_record_state(params['id'], "DC-AMEND", "Amendment request; #{params['reason']}")

    redirect_to (params[:next_path]? params[:next_path] : "/manage_requests")
  end

  def do_reprint

    status = ""
    if params['reason'].to_s.upcase == "LOST"
     status = "DC-LOST"
    else
     status = "DC-DAMAGED"
    end

    #PersonRecordStatus.new_record_state(params['id'], status, "Reprint request; #{params['reason']}");
    PersonRecordStatus.new_record_state(params['id'], "HQ-CAN-PRINT", "Reprint request; #{params['reason']}");
    pbd = PersonBirthDetail.where(person_id: params['id']).last

    i = 1
    for i in 1..20 do
        pbd.save
    end

    redirect_to session['list_url']
  end

  def approve_reprint_request
    PersonRecordStatus.new_record_state(params['id'], "HQ-#{params['reason'].upcase}", "Reprint request; #{params['reason']}");
    pbd = PersonBirthDetail.where(person_id: params['id']).last

    i = 1
    for i in 1..20 do
        pbd.save
    end
    redirect_to session['list_url']
  end

  def approve_amendment_request
    PersonRecordStatus.new_record_state(params['id'], "HQ-AMEND", "Amendment request; Verifed by ADR");
    prs = PersonRecordStatus.where(person_id: params['id'], status_id: 23, voided: 0).order('created_at DESC').first
    
    i = 1

    for i in 1..20 do
        prs.save
    end

    redirect_to session['list_url']
  end

  def searched_cases

    @states = Status.all.map(&:name)
    @section = "Search Cases"
    @display_ben = true
    @search = true
    @user = User.find(params[:user_id]) rescue nil
    User.current = @user if !@user.blank?

    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states) rescue nil
    filters = JSON.parse(params['data']) rescue {}
    @records = PersonService.search_results(filters)
    render :template => "person/records", :layout => "data_table"
  end
  #########################################################################

  def paginated_data
      search_val = params[:search][:value] rescue nil
      search_val = '_' if search_val.blank?

      if params[:type] == 'All'
        types=['Normal', 'Abandoned', 'Adopted', 'Orphaned']
      else
        types=[params[:type]]
      end
      #AND person_birth_details.birth_registration_type_id IN (SELECT birth_registration_type_id FROM birth_registration_type WHERE name IN('#{types.join("','")}'))
      query = "SELECT
                       person.person_id,
                       person_birth_details.district_id_number as ben,
                       national_serial_number,
                       pn.first_name, 
                       pn.last_name, 
                       gender, 
                       birthdate, 
                       mn.first_name as mother_first_name,
                       mn.last_name as mother_last_name,
                       fn.first_name as father_first_name,
                       fn.last_name as father_last_name,
                       s.name as status,
                       person_birth_details.acknowledgement_of_receipt_date as date_reported,
                       person_birth_details.created_at
                    FROM person 
                    INNER JOIN person_name pn INNER JOIN person_birth_details
                    INNER JOIN person_relationship prm INNER JOIN person_name mn
                    INNER JOIN person_relationship prf INNER JOIN person_name fn
                    INNER JOIN person_relationship pri INNER JOIN person_addresses fa
                    INNER JOIN person_record_statuses ps
                    INNER JOIN statuses s
                    ON person.person_id = pn.person_id 
                      AND person.person_id = person_birth_details.person_id
                      AND person.person_id = prm. person_a
                      AND prm.person_b = mn.person_id
                      AND person.person_id = prf. person_a
                      AND prf.person_b = fn.person_id
                      AND person.person_id = ps.person_id
                      AND ps.status_id = s.status_id
                    WHERE prm.person_relationship_type_id = 5
                      AND pn.voided = 0 AND mn.voided = 0
                      AND fn.voided =0 AND prf.person_relationship_type_id = 1
                      AND pri.person_relationship_type_id = 4
                      AND person.person_id = pri. person_a
                      AND prf. person_b = fa.person_id
                      AND ps.voided = 0
                      AND s.name IN('#{params[:statuses].split(',').join("','")}')
                      AND person_birth_details.location_created_at IN(
                        SELECT #{SETTINGS['location_id']} as location_id UNION SELECT location_id FROM location WHERE parent_location=#{SETTINGS['location_id']} UNION SELECT location_id FROM location WHERE parent_location IN(SELECT location_id FROM location where parent_location=#{SETTINGS['location_id']})
                      )
                      AND concat_ws('_', person_birth_details.national_serial_number, person_birth_details.district_id_number, pn.first_name, pn.last_name, pn.middle_name,
                    person.birthdate, person.gender) REGEXP \"#{search_val}\"
                    ORDER BY created_at DESC 
                    LIMIT #{params[:length].to_i} OFFSET #{(params[:draw].to_i - 1) * params[:length].to_i };"
         
        data = ActiveRecord::Base.connection.select_all(query)

        @records = []
        data.each do |p|
            #raise p.inspect
            row = []
        row = [p['ben']] if params[:assign_ben] == 'true'
        row << PersonIdentifier.by_type(p.person_id, "Verification Number") if params[:vnum]         == 'true'
        row = row + [
                "#{p['first_name']} #{p['last_name']} (#{p['gender']})",
                p['birthdate'].strftime('%d/%b/%Y'),
                "#{p['mother_first_name']} #{p['mother_last_name']}",
                "#{p['father_first_name']} #{p['father_last_name']}",
                (p['date_reported'].strftime('%d/%b/%Y') rescue nil),
                p['status'],
                p['person_id']

            ]
            @records << row
          end
         render :text => {
          "draw" => params[:draw].to_i,
          "recordsTotal" => 10000,
          "recordsFiltered" => 10000,
          "data" => @records}.to_json and return 
      
  end
  

  def paginated_data_back
    params[:statuses] = [] if params[:statuses].blank?
    states = params[:statuses].split(',')
    types = []

    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?
    if !params[:start].blank?

      state_ids = states.collect{|s| Status.find_by_name(s).id} + [-1]

      if params[:type] == 'All'
        types=['Normal', 'Abandoned', 'Adopted', 'Orphaned']
      else
        types=[params[:type]]
      end

      person_reg_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

      #faulty_ids = [-1] + PersonRecordStatus.find_by_sql("SELECT prs.person_record_status_id FROM person_record_statuses prs
      #                                          LEFT JOIN person_record_statuses prs2 ON prs.person_id = prs2.person_id AND prs.voided = 0 AND prs2.voided = 0
       #                                         WHERE prs.created_at < prs2.created_at;").map(&:person_record_status_id)

      by_ds_at_filter = ""
      pid_type_ver_id = PersonIdentifierType.where(name: "Verification Number").first.id
      if params[:by_ds_at_dro].to_s == "true"
        by_ds_at_filter = " INNER JOIN person_identifiers pidr ON pidr.person_id = prs.person_id
          AND pidr.person_identifier_type_id = #{pid_type_ver_id} AND pidr.voided = 0 "
      end

      d = Person.order(" cp.created_at DESC ")
      .joins(" INNER JOIN core_person cp ON person.person_id = cp.person_id
              INNER JOIN person_name n ON person.person_id = n.person_id
              INNER JOIN person_record_statuses prs ON person.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
              INNER JOIN person_birth_details pbd ON person.person_id = pbd.person_id
              #{by_ds_at_filter} ")
      .where(" prs.status_id IN (#{state_ids.join(', ')})
              AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')})
              AND prs.created_at = (SELECT MAX(created_at) FROM person_record_statuses prs2 WHERE prs2.person_id = person.person_id)
              AND concat_ws('_', pbd.national_serial_number, pbd.district_id_number, n.first_name, n.last_name, n.middle_name,
                person.birthdate, person.gender) REGEXP \"#{search_val}\" ")

      total = d.select(" count(*) c ")[0]['c'] rescue 0
      page = (params[:start].to_i / params[:length].to_i) + 1

      data = d.group(" prs.person_id ")

      data = data.select(" n.*, prs.status_id, pbd.district_id_number AS ben, person.gender, person.birthdate, pbd.national_serial_number AS brn, pbd.date_reported ")
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
        row << PersonIdentifier.by_type(p.person_id, "Verification Number") if params[:vnum]         == 'true'
        row = row + [
            "#{name} (#{p.gender})",
            p.birthdate.strftime('%d/%b/%Y'),
            mother_name,
            father_name,
            (p.date_reported.strftime('%d/%b/%Y') rescue nil),
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

  def paginated_search_data
    filters = JSON.parse(params['data']) rescue {}
    @records = PersonService.search_results(filters, params)

    render text: @records.to_json
  end

  def search_by_nid
    data = []
    nid_type_id = PersonIdentifierType.where(name: "National ID Number").last.id

    nids = PersonIdentifier.where(person_identifier_type_id: nid_type_id, voided: 0, value: params[:nid])

    nids.each do |id|
      person = Person.find(id.person_id)

      next if !params[:gender].blank? && (person.gender.to_s != params[:gender].to_s)
      name = PersonName.where(person_id: id.person_id).last
      next if name.blank?

      address = PersonAddress.where(person_id: id.person_id).last

      data << {
          'first_name'    => (name.first_name rescue ''),
          'last_name'     => (name.last_name rescue ''),
          'gender'        => (({'F' => 'Female', 'M' => 'Male'}[person.gender]) rescue nil),
          'birthdate'     =>  (person.birthdate.strftime("%d-%b-%Y") rescue nil),
          'home_district' => (Location.find(address.home_district).name rescue nil),
          'home_ta'       => (Location.find(address.home_ta).name rescue nil),
          'home_village'  => (Location.find(address.home_village).name rescue nil),
          'person_id'     => id.person_id
      }
    end

    render text: data.to_json
  end

  def check_sync
    sync = Syncs.where(person_id: params['person_id'])
			
		details = PersonBirthDetail.where(person_id: params['person_id']).last
		if details.district_id_number.blank?
			render :text => {'person_id' => params['person_id'],
                       'result' => 'false'}.to_json and return
		end 		

    if !sync.blank?
      render :text => {'person_id' => params['person_id'],
                       'result' => 'true'}.to_json and return
    end

    url = SETTINGS['destination_app_link'] + "/sync_status?person_id=#{params['person_id']}"
    result = RestClient.get(url) rescue 'false'

    if result.to_s == 'true'
      sync = Syncs.where(person_id: params['person_id'])
      if sync.blank?
        Syncs.create(
            level: SETTINGS['application_mode'],
            person_id: params['person_id']
        )
      end
    end

    render :text => {'person_id' => params['person_id'],
                     'result' => result}.to_json
  end

	def check_serial_number

		render text: PersonService.get_identifier(params[:person_id], "Facility Number")
		 
	end

  def print_registration(person_id, redirect)
			
			if redirect.split("").include?("?")
				symbol = "&"
			else
				symbol = "?"
			end

			redirect_to "#{redirect}#{symbol}print_reg=true&person_id=#{person_id}" and return unless redirect.match("print_reg")
			
    	print_and_redirect("/person_id_label?person_id=#{person_id}", redirect)		
  end

  def person_id_label
    person = Person.find(params[:person_id])
    print_string = person_label(person)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:person_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def person_label(person)

    sex =  person.gender.match(/F/i) ? "(F)" : "(M)"
    name = PersonName.where(person_id: person.id).last
    details = PersonBirthDetail.where(person_id: person.id).first
    place_of_birth = Location.find(SETTINGS['location_id']).name
    birth_district = Location.find(details.district_of_birth).name
    mother_name = PersonService.mother(person.person_id)
    informant_name = PersonService.informant(person.person_id)

    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{details.facility_serial_number}")
    label.draw_multi_text("ID Number: #{details.facility_serial_number}")
    label.draw_multi_text("Child: #{name.first_name + ' ' + name.last_name} #{sex}")
    label.draw_multi_text("DOB: #{person.birthdate.to_date.strftime("%d/%b/%Y")}")
    label.draw_multi_text("Birth Place: #{place_of_birth} / #{birth_district}")
    label.draw_multi_text("Mother: #{mother_name.first_name + ' ' + mother_name.last_name}")
    label.draw_multi_text("Child Informant: #{informant_name.first_name + ' ' + informant_name.last_name}")
    label.draw_multi_text("Date of Reporting: #{(details.acknowledgement_of_receipt_date.strftime('%d/%B/%Y') rescue nil)}")
    label.print(1)
  end

 def receive_data

    User.current = User.where(username: "admin#{SETTINGS['location_id']}").first if User.current.blank?
    data = params["data"]

    File.open("#{Rails.root}/dump.csv", "w"){|f|
      f.write(data)
    }

    ActiveRecord::Base.transaction do
      if MassPerson.load_mass_data

=begin
        upload_number   = MassPerson.find_by_sql(" SELECT MAX(upload_number) n FROM mass_person ").last['n'].to_i + 1
        MassPerson.where(upload_status: "NOT UPLOADED").each do |record|
          record.map_to_ebrs_tables(upload_number)
        end
=end

      end
    end

    render :text => "OK"
 end


  def print
    
    print_errors = {}
    print_error_log = Logger.new(Rails.root.join("log","print_error.log"))
    paper_size = GlobalProperty.find_by_property("paper_size").value rescue 'A5'

    if paper_size == "A4"
      zoom = 0.83
    elsif paper_size == "A5"
      zoom = 0.89
    end

    #person_ids = params[:person_ids].split(',')
    person_ids = params[:person_ids]
    person_ids.each do |person_id|
      #begin
      print_url = "wkhtmltopdf --zoom #{zoom} --page-size #{paper_size} #{SETTINGS["protocol"]}://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/birth_certificate?person_ids=#{person_id.strip} #{SETTINGS['certificates_path']}#{person_id.strip}.pdf\n"

      print_error_log.debug print_url
      puts print_url

      PersonRecordStatus.new_record_state(person_id, 'DC-PRINTED', 'Printed Child Record')
      t4 = Thread.new {
        Kernel.system print_url
        Kernel.system "lp -d #{params[:printer_name]} #{SETTINGS['certificates_path'].strip}#{person_id.strip}.pdf\n"
      }
    end

    if print_errors.present?
      print_errors.each do |k,v|
        print_error_log.debug "#{k} : #{v}"
      end
    end

    if !session[:list_url].blank?
      redirect_to session[:list_url]
    else
      redirect_to "/"
    end
  end

  def print_preview
    @section = "Print Preview"
    @available_printers = SETTINGS["printer_name"].split('|')
    render :layout => false
  end

  def birth_certificate

    @data = []
    signatory = User.find_by_username(GlobalProperty.find_by_property("signatory").value) rescue nil
    signatory_attribute_type = PersonAttributeType.find_by_name("Signature") if signatory.present?
    @signature = PersonAttribute.find_by_person_id_and_person_attribute_type_id(signatory.id,signatory_attribute_type.id).value rescue nil
    @signature = "signature.png" if @signature.blank? 

    person_ids = params[:person_ids].split(',')
    nid_type = PersonIdentifierType.where(name: "Barcode Number").last

    person_ids.each do |person_id|
      data = {}
      data['person'] = Person.find(person_id) rescue nil
      data['birth']  = PersonBirthDetail.where(person_id: person_id).last

      barcode = File.read("qr_#{SETTINGS['barcodes_path']}#{person_id}.png") rescue nil

      if (barcode.blank?)

=begin
        barcode_value = PersonIdentifier.where(person_id: person_id,
                                               person_identifier_type_id: nid_type.id, voided: 0
        ).last.value rescue nil

        if barcode_value.blank?

          bcd = BarcodeIdentifier.where(assigned: 0).first
          bcd.person_id = person_id
          bcd.assigned  = 1
          bcd.save

          p = PersonIdentifier.new
          p.person_id = person_id
          p.value = bcd.value
          p.person_identifier_type_id = PersonIdentifierType.where(name: "Barcode Number").last.id
          p.save

          barcode_value = bcd.value
        end
=end
        barcode_value = ""
        PersonBirthDetail.generate_barcode(barcode_value, person_id, SETTINGS['barcodes_path'])
      end

      @data << data
    end

    render :layout => false, :template => 'person/birth_certificate'
  end

  def person_id_details

    if !params[:verification_number].blank?

      pid_type_id = PersonIdentifierType.where(name: "Verification Number").first.id
      pid = PersonIdentifier.where(value: params[:verification_number],
                                   voided: 0,
                                   person_identifier_type_id: pid_type_id).first

      if pid.blank?
        render :text => {}.to_json and return
      else
        render :text => {"verification_number_exists" => true}.to_json and return
      end
    end

    name = PersonName.where(person_id: params[:person_id]).first
    address = PersonAddress.where(person_id: params[:person_id]).first

    data = {
      first_name: name.first_name,
      last_name:  name.last_name,
      middle_name: name.middle_name,
      citizenship: (Location.find(address.citizenship).country rescue nil)
    }

    render :text => data.to_json and return
  end

  def ajax_assign_single_national_id
    person_id = params[:person_id]
    r = nil

    person = Person.find(person_id)
    id_number = person.id_number

    if id_number.present?
      r = ["RECORD ALREADY HAS NID: #{id_number}", id_number]
    else
      r  = PersonService.request_nris_id_remote(person_id)
    end

    render :text => r.to_json
  end


  def force_sync
    value = PersonService.force_sync_remote(params[:person_id]) rescue false
    render :text => value.to_s
  end

  def remote_auth
    if params[:token].blank?
      user = User.where(username: params[:username], active: 1).first
      if user and user.password_matches?(params[:password])
        random_token = SecureRandom.urlsafe_base64(nil, false)
        Kernel.system("cd #{Rails.root}/tmp/sessions/ && touch #{random_token}")
        render :text =>{:action => "success", :token => random_token, :remote_expires_at => 30.minutes.from_now.to_time}.to_json
      else
        render :text => {:action =>'Failed'}.to_json
      end
    else
       if File.exist?("#{Rails.root}/tmp/sessions/#{params[:token]}") && Time.now < params[:remote_expires_at].to_time
          render :text => {:action => "success", :token=> params[:token], :remote_expires_at => 30.minutes.from_now.to_time}.to_json
       else
          render :text => {:action =>'Failed'}.to_json
       end
    end
  end

  def create_child_remote
    if params[:token].present?
      if File.exist?("#{Rails.root}/tmp/sessions/#{params[:token]}") && Time.now < params[:remote_expires_at].to_time
        person = PersonService.create_record(params)
        render :text => {:person =>person, :remote_expires_at =>30.minutes.from_now.to_time, :token => params[:token], :remote_id => params[:person_id] }.to_json
     else
        render :text => {:action =>'Failed'}.to_json and return
     end
    end
  end

end
