class PersonController < ApplicationController
  def index

    @icoFolder = icoFolder("icoFolder")
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
    @targeturl = "/logout"
    @targettext = "Logout"
    render :layout => 'facility'
    
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
                "Home Address, Village/Town" => "#{loc(@mother_address.home_district, 'District') rescue nil}",
                "T/A" => "#{loc(@mother_address.home_ta, 'Traditional Authority') rescue nil}",
                "District" => "#{loc(@mother_address.home_village, 'Village') rescue nil}"
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
                "Home Address, Village/Town" => "#{loc(@father_address.home_district, 'District') rescue nil}",
                "T/A" => "#{loc(@father_address.home_ta, 'Traditional Authority') rescue nil}",
                "District" => "#{loc(@father_address.home_village, 'Village') rescue nil}"
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
                "Physical Address, District" => "#{loc(@informant_address.home_district, 'District')rescue nil}",
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

    render :layout => "facility"
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

    @current_district = Location.current_district.name

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

  params[:district] =map[params[:district]] if   params[:district].match(/City$/)

  nationality_tag = LocationTag.where("name = 'Hospital' OR name = 'Health Facility'").first
  data = []
  parent_location = Location.where(name: params[:district]).last.id rescue nil

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
    @states = ["DC-ACTIVE"]
    @section = "New Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    
    @records = PersonService.query_for_display(@states)
   
    render :template => "person/records", :layout => "data_table"
  end

  def view_complete_cases
    @states = ["DC-COMPLETE"]
    @section = "Complete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_incomplete_cases
    @states = ["DC-INCOMPLETE"]
    @section = "Incomplete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

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
    @states = ['DC-AMMEND']
    @section = "Ammendments"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
    @display_ben = true
    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end
  #########################################################################

end
