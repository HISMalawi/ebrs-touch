class PersonController < ApplicationController
  def index

    @icoFolder = icoFolder("icoFolder")
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
    @targeturl = "/logout"
    @targettext = "Logout"
    render :layout => 'facility'
    
  end

  def show

    if params[:next_path].blank?
      @targeturl = request.referrer
    else
      @targeturl = params[:next_path]
    end

    @section = "View Record"
    person_mother_id = PersonRelationType.find_by_name("Mother").id
    person_father_id = PersonRelationType.find_by_name("Father").id
    informant_type_id = PersonType.find_by_name("Informant").id
    

    @relations = PersonRelationship.find_by_sql(['select * from person_relationship where person_a = ?', params[:id]]).map(&:person_b)

    

    @informant_id = PersonRelationship.where(person_a: params[:id], person_relationship_type_id: informant_type_id).first.person_b 
    
    
    person_mother_relation = PersonRelationship.find_by_sql(["select * from person_relationship where person_a = ? and person_relationship_type_id = ?",params[:id], person_mother_id])
    mother_id = person_mother_relation.map{|relation| relation.person_b} #rescue nil
    father_id = PersonRelationship.where(person_a: params[:id],
                                          person_relationship_type_id: person_father_id).first.person_b rescue nil

    @person_name = PersonName.find_by_person_id(params[:id])
    @person = Person.find(params[:id])
    @core_person = CorePerson.find(params[:id])
    @birth_details = PersonBirthDetail.find_by_person_id(params[:id])
    
    @person_record_status = PersonRecordStatus.where(:person_id => params[:id]).last
    @person_status = @person_record_status.status.name

    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, [@person_status])

    @mother = Person.find(mother_id)
    @father = Person.find(father_id) rescue nil
    @mother_name = PersonName.find_by_person_id(mother_id)
    @father_name = PersonName.find_by_person_id(father_id)
    @mother_address = PersonAddress.find_by_person_id(mother_id)
    @father_address = PersonAddress.find_by_person_id(father_id)


    @informant = Person.find(@informant_id)
    @informant_name = PersonName.find_by_person_id(@informant_id)
    @informant_address = PersonAddress.find_by_person_id(@informant_id)

    
    @record = {
        "Details of Child" => [
            {
                "Birth Entry Number" => "#{@person_details.district_id_number rescue nil}",
                "Birth Registration Number" => "#{@person_name.national_serial_number rescue nil}"
            },

            {
                ["First Name","mandatory"] => "#{@person_name.first_name rescue nil}",
                "Other Name" => "#{@person_name.middle_name rescue nil}",
                ["Surname", "mandatory"] => "#{@person_name.last_name rescue nil}"
            },
            {
                ["Date of birth" , "mandatory"] => "#{@person.birthdate rescue nil}",
                ["Sex", "mandatory"] => "#{@person.gender rescue nil}",
                "Place of birth" => "#{Location.find(@birth_details.place_of_birth).name rescue nil}"
                
            },
            {
                "Name of Hospital" => "#{Location.find(@birth_details.birth_location_id).name rescue nil}",
                "Other Details" => "#{@person.other_birth_place_details rescue nil}",
                "Address" => "#{@person.birth_address rescue nil}"
            },
            {
                #{}"District" => "#{@person.birth_district rescue nil}",
                "District" => "#{Location.find(@mother_address.current_district).name rescue nil}",
                "T/A" => "#{@person.birth_ta rescue nil}",
                "Village" => "#{@person.birth_village rescue nil}"
            },
            {
                "Birth weight (kg)" => "#{@birth_details.birth_weight rescue nil}",
                "Type of birth" => "#{PersonTypeOfBirth.find(@birth_details.type_of_birth).name rescue nil}",
                "Other birth specified" => "#{@birth_details.other_type_of_birth rescue nil}"
            },
            {
                "Are the parents married to each other?" => "#{@birth_details.parents_married_to_each_other ? "Yes" : "No" rescue nil}",
                "If yes, date of marriage" => "#{@birth_details.date_of_marriage rescue nil}"
            },
            {
                "Court Order Attached?" => "#{@birth_details.court_order_attached ? "Yes" : "No" rescue nil}",
                "Parents Signed?" => "#{@person.parents_signed rescue nil}",
                "Record Complete?" => "YES" #{ (record_complete?(@person) == false ? 'No' : 'Yes')}",

            },
            {
                "Place where birth was recorded" => "", #@person.place_birth_was_recorded",
                "Record Status" => "<div id='status'>#{@person_status rescue nil}</div>",
                "Child Type" => "#{@person.relationship.titleize rescue nil}",
            }


        ],
        "Details of Child's Mother" => [
            {
                ["First Name", "mandatory"] => "#{@mother_name.first_name rescue nil}",
                "Other Name" => "#{@mother_name.middle_name rescue nil}",
                ["Maiden Surname", "mandatory"] => "#{@mother_name.last_name rescue nil}"
            },
            {
                ["Date of birth", "mandatory"] => "#{Person.find_by_person_id(mother_id).birthdate rescue nil}",
                "Nationality" => "#{Location.find(@mother_address.citizenship).name rescue nil}",
                "ID Number" => "#{@person.mother.id_number rescue nil}"
            },
            {
                "Physical Residential Address, District" => "#{(Location.find(@mother_address.current_district).name ||
                    @person.mother.foreigner_current_district) rescue nil}",
                "T/A" => "#{(Location.find(@mother_address.current_ta).name ||
                    @person.mother.foreigner_current_ta) rescue nil}",
                "Village/Town" => "#{(Location.find(@mother_address.current_village).name||
                    @person.mother.foreigner_current_village) rescue nil}"
            },
            {
                "Home Address, Village/Town" => "#{Location.find(@mother_address.home_village).name rescue nil}",
                "T/A" => "#{Location.find(@mother_address.home_ta).name rescue nil}",
                "District" =>  "#{Location.find(@mother_address.current_district).name rescue nil}"
            },
            {
                "Gestation age at birth in weeks" => "#{@birth_details.gestation_at_birth rescue nil}",
                "Number of prenatal visits" => "#{@birth_details.number_of_prenatal_visits rescue nil}",
                "Month of pregnancy prenatal care started" => "#{@birth_details.month_prenatal_care_started rescue nil}"
            },
            {
                "Mode of delivery" => "#{ModeOfDelivery.find(@birth_details.mode_of_delivery_id).name rescue nil}",
                "Number of children born to the mother, including this child" => "#{@birth_details.number_of_children_born_alive_inclusive rescue nil}",
                "Number of children born to the mother, and still living" => "#{@birth_details.number_of_children_born_still_alive rescue nil}"
            },
            {
                "Level of education" => "#{LevelOfEducation.find(@birth_details.level_of_education_id).name rescue nil}"
            }
        ],

        "Details of Child's Father" => [
            {
                parents_married(@birth_details.parents_married_to_each_other, "First Name") => "#{@father_name.first_name rescue nil}",
                "Other Name" => "#{@father_name.middle_name rescue nil}",
                parents_married(@birth_details.parents_married_to_each_other, "Surname") => "#{@father_name.last_name rescue nil}"
            },
            {
                "Date of birth" => "#{@father.birthdate rescue nil}",
                "Nationality" => "#{Location.find(@father_address.citizenship).name rescue nil}",
                "ID Number" => "#{@father.id_number rescue nil}"
            },
            {
                "Physical Residential Address, District" => "#{(Location.find(@father_address.current_district).name ||
                    @father.foreigner_current_district) rescue nil}",
                "T/A" => "#{(Location.find(@father_address.current_ta).name ||
                    @person.father.foreigner_current_ta) rescue nil}",
                "Village/Town" => "#{(Location.find(@father_address.current_village).name ||
                    @person.father.foreigner_current_village) rescue nil}"
            },
            {
                "Home Address, Village/Town" => "#{Location.find(@father_address.home_village).name rescue nil}",
                "T/A" => "#{Location.find(@father_address.home_ta).name rescue nil}",
                "District" =>  "#{Location.find(@father_address.current_district).name rescue nil}"
            }
        ],

        "Details of Child's Informant" => [
            {
                "First Name" => "#{@informant_name.first_name rescue nil}",
                "Other Name" => "#{@informant_name.middle_name rescue nil}",
                "Family Name" => "#{@informant_name.last_name rescue nil}"
            },
            {
                "Relationship to child" => "#{PersonRelationType.find(PersonRelationship.find_by_person_b(@informant_id).person_relationship_type_id).name rescue ""}",
                "ID Number" => "#{@person.informant.id_number rescue ""}"
            },
            {
                "Physical Address, District" => "#{Location.find(@informant_address.current_district).name rescue nil}",
                "T/A" => "#{Location.find(@informant_address.current_ta).name rescue nil}",
                "Village/Town" => "#{Location.find(@informant_address.current_village).name rescue nil}"
            },
            {
                "Postal Address" => "#{@informant_address.address_line_1 rescue nil}",
                " " => "#{@informant_address.address_line_2 rescue nil}",
                "City" => "#{Location.find(@informant_address.current_district).name rescue nil}"
            },
            {
                "Phone Number" => "#{@person.informant.phone_number rescue ""}",
                "Informant Signed?" => "#{@person.form_signed rescue ""}"
            },
            {
                "Acknowledgement Date" => "#{@person.acknowledgement_of_receipt_date.strftime('%d/%b/%Y') rescue ""}",
                "Date of Registration" => "#{@person.date_registered.to_date.strftime('%d/%b/%Y') rescue ""}",
                "Delayed Registration <br /><font size='1'  style='color: grey;'><i>({answer})</i></font>" => "{delayed}"
            }
        ]
    }

  

    @summaryHash = {
      "Child Name" => "#{@person_name.first_name} #{@person_name.middle_name rescue nil} #{@person_name.last_name rescue nil}",
      "Child Gender" => ({'M' => 'Male', 'F' => 'Female'}[@person.gender.strip.split('')[0]] rescue @person.gender),
      "Child Date of Birth" => @person.birthdate.to_date.strftime("%d/%b/%Y"),
      "Place of Birth" => "#{Location.find(@birth_details.birth_location_id).name rescue nil}",
      "Child's Mother " => "#{@mother_name.first_name rescue nil} #{@mother_name.middle_name rescue nil} #{@mother_name.last_name rescue nil}",
      "Child's Father" =>  "#{@father_name.first_name rescue nil} #{@father_name.middle_name rescue nil} #{@father_name.last_name rescue nil}",
      "Parents Married" => (@birth_details.parents_married_to_each_other == 1 ? 'Yes' : 'No'),
      "Court order attached" => (@birth_details.court_order_attached == 1 ? 'Yes' : 'No'),
      "Parents signed?" => ((@birth_details.parents_signed rescue -1) == 1 ? 'Yes' : 'No'),
      "Delayed Registration" => ((@person.created_at.to_date - @person.birthdate.to_date).to_i > 42 ? 'Yes' : 'No')
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
    
    $prev_child_id = params[:id]
    
    if params[:id].blank?
      
      @person = PersonName.new

      @section = "New Person"

    else
      
      @person = PersonBirthDetail.find_by_person_id(params[:id])
      @person_name = PersonName.find_by_person_id(params[:id])

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

    if @person.present? && SETTINGS['potential_search']
      person = {}
      person["id"] = @person.person_id
      person["first_name"]= params[:person][:first_name]
      person["last_name"] =  params[:person][:last_name]
      person["middle_name"] = params[:person][:middle_name]
      person["gender"] = params[:person][:gender]
      person["birthdate"]= params[:person][:birthdate]
      person["birthdate_estimated"] = params[:person][:birthdate_estimated]
      person["nationality"]=  params[:person][:mother][:citizenship]
      person["place_of_birth"] = params[:person][:place_of_birth]
      person["district"] = params[:person][:birth_district]
      person["mother_first_name"]= params[:person][:mother][:first_name]
      person["mother_last_name"] =  params[:person][:mother][:last_name]
      person["mother_middle_name"] = params[:person][:mother][:middle_name]
      person["father_first_name"]= params[:person][:father][:first_name]
      person["father_last_name"] =  params[:person][:father][:last_name]
      person["father_middle_name"] = params[:person][:father][:middle_name]

      SimpleElasticSearch.add(person)
    else

    end
  

    if ["First Twin", "First Triplet", "Second Triplet"].include?(type_of_birth.strip)
      
      redirect_to "/person/new?id=#{@person.id}"

    else

       if application_mode == 'Facility'

          redirect_to '/records/DC-Complete'

        else

          redirect_to '/view_cases'

        end
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

      people = []

      if SETTINGS['potential_search']
        if params[:type_of_birth] &&  params[:type_of_birth].include?("Twin")         
          results = []
        else
          results = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision'])
        end
      else
        results = []
      end

      people = results

      if people.count == 0

        render :text => {:response => false}.to_json
      else

        render :text => {:response => people}.to_json
      end 
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
    @states = ["DC-PENDING"]
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

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_printed_cases
    @states = ["HQ-PRINTED", 'HQ-DISPATCHED']
    @section = "Printed Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

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

  #########################################################################

end
