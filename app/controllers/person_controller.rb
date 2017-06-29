class PersonController < ApplicationController
  def index

    @icoFolder = icoFolder("icoFolder")
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
    @targeturl = "/logout"
    @targettext = "Logout"
    render :layout => 'facility'
    
  end

  def show

    @targeturl = request.referrer
    @section = "View Record"
    person_mother_id = PersonRelationType.find_by_name("Mother").id
    person_father_id = PersonRelationType.find_by_name("Father").id
    informant_type_id = PersonType.find_by_name("Informant").id

    @relations = PersonRelationship.find_by_sql(['select * from person_relationship where person_a = ?', params[:id]]).map(&:person_b)
    @informant_id = CorePerson.find_by_sql(['select * from core_person
                    where person_type_id = ?
                    and person_id in (?)',informant_type_id, @relations]).map(&:person_id)

    #raise @informant.inspect

    person_mother_relation = PersonRelationship.find_by_sql(["select * from person_relationship where person_a = ? and person_relationship_type_id = ?",params[:id], person_mother_id])
    mother_id = person_mother_relation.map{|relation| relation.person_b} #rescue nil
    father_id = PersonRelationship.find(:conditions => ["person_a = ? and person_relationship_type_id = ?", params[:id], person_father_id]).person_b rescue nil


    @person_name = PersonName.find_by_person_id(params[:id])
    @person = Person.find(params[:id])
    @core_person = CorePerson.find(params[:id])
    @birth_details = PersonBirthDetail.find_by_person_id(params[:id])
    @person_record_status = PersonRecordStatus.find_by_person_id(params[:id])
    @person_status = @person_record_status.status.name

    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, [@person_status])

    @mother = Person.find(mother_id)
    @mother_name = PersonName.find_by_person_id(mother_id)
    @mother_address = PersonAddress.find_by_person_id(mother_id)


    @informant = Person.find(@informant_id)
    @informant_name = PersonName.find_by_person_id(@informant_id)

  #raise @informant.inspect

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
                "District" => "#{@person.birth_district rescue nil}",
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
                ["Date of birth", "mandatory"] => "#{@mother.birthdate rescue nil}",
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
                "District" =>  "#{Location.find(@mother_address.home_district).name rescue nil}"
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
=begin
    r = {
        "Details of Child's Father" => [
            {
                parents_married(@person, "First Name") => "#{@person.father.first_name rescue nil}",
                "Other Name" => "#{@person.father.middle_name rescue nil}",
                parents_married(@person, "Surname") => "#{@person.father.last_name rescue nil}"
            },
            {
                "Date of birth" => "#{@person.father.birthdate rescue nil}",
                "Nationality" => "#{@person.father.citizenship rescue nil}",
                "ID Number" => "#{@person.father.id_number rescue nil}"
            },
            {
                "Physical Residential Address, District" => "#{(@person.father.current_district ||
                    @person.father.foreigner_current_district) rescue nil}",
                "T/A" => "#{(@person.father.current_ta ||
                    @person.father.foreigner_current_ta) rescue nil}",
                "Village/Town" => "#{(@person.father.current_village ||
                    @person.father.foreigner_current_village) rescue nil}"
            },
            {
                "Home Address, Village/Town" => "#{@person.father.home_village rescue nil}",
                "T/A" => "#{@person.father.home_ta rescue nil}",
                "District" =>  "#{@person.father.home_district rescue nil}"
            }
        ],
=end
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
                "Physical Address, District" => "#{@person.informant.current_district rescue nil}",
                "T/A" => "#{@person.informant.current_ta rescue nil}",
                "Village/Town" => "#{@person.informant.current_village rescue nil}"
            },
            {
                "Postal Address" => "#{@person.informant.addressline1 rescue nil}",
                " " => "#{@person.informant.addressline2 rescue nil}",
                "City" => "#{@person.informant.city rescue nil}"
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
      "Child Gender" => @person.gender,
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
    render :layout => 'data_table'
  end

  def new
    

    if params[:id].blank?
      @person = PersonName.new

      @section = "New Person"
    else
      @person = PersonBirthDetail.find_by_person_id(params[:id])
      @person_name = PersonName.find_by_person_name_id(params[:id])
      #raise params[:id].inspect
    end

     render :layout => "touch"
  end

  def create
    type_of_birth = params[:person][:type_of_birth]
    @person = PersonService.create_record(params)
    if ["Twin", "Triplet", "Second Triplet"].include?(type_of_birth.strip)
      redirect_to "/person/new?id=#{@person.id}"
    else
      redirect_to '/'
    end

  end

  #########################################################################
  
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
  
  nationality_tag = LocationTag.where(name: 'Health facility').first
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

  def view_sync
     render :layout => "facility"
  end

  def view_complete_cases
    @states = ["DC-COMPLETE", "DC-ACTIVE"]
    @title = "Complete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_incomplete_cases
    @states = ["DC-INCOMPLETE"]
    @title = "Complete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  def view_active_cases
    @states = ["DC-ACTIVE"]
    @title = "Complete Cases"
    @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)
    render :template => "person/records", :layout => "data_table"
  end

  #########################################################################

end
