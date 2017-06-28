module PersonService
	require 'bean'
	require 'json'

  def self.create_record(params)
    #raise params.inspect

    adoption_court_order              = params[:person][:adoption_court_order] rescue nil
    desig                             = params[:person][:informant][:designation] rescue nil
    birth_place_details_available     = params[:birth_place_details_available]
    parents_details_available         = params[:parents_details_available]
    biological_parents                = params[:biological_parents]
    foster_parents                    = params[:foster_parents]

    first_name 			                  = params[:person][:first_name]
    last_name 			                  = params[:person][:last_name]
    middle_name 		                  = params[:person][:middle_name]
    birthdate                         = params[:birthdate]
    place_of_birth		                = params[:person][:place_of_birth]
    hospital_of_birth	                =	params[:person][:hospital_of_birth]
    birth_district		                =	params[:person][:birth_district]
    birth_weight		                  = params[:person][:birth_weight]
    acknowledgement_of_receipt_date	  = params[:person][:acknowledgement_of_receipt_date]
    gender 				      	            = params[:person][:gender]
    home_address_same_as_physical     = params[:person][:home_address_same_as_physical]
    same_address_with_mother	        = params[:person][:same_address_with_mother]
    registration_type 	              = params[:person][:registration_type]
    copy_mother_name                  = params[:person][:copy_mother_name]
    type_of_birth		                  = params[:person][:type_of_birth]

    #raise birthdate.inspect

    ################################ mother details ###############################################

      mother_last_name 	                =	params[:person][:mother][:last_name]
      mother_first_name	                =	params[:person][:mother][:first_name]
      mother_middle_name	              =	params[:person][:mother][:middle_name]
      mother_birthdate	                =	params[:person][:mother][:birthdate]
      mother_citizenship	              =	params[:person][:mother][:citizenship]
      mother_residental_country         = params[:person][:mother][:residential_country]
      mother_foreigner_current_district = params[:person][:mother][:foreigner_current_district]
      mother_foreigner_current_village  = params[:person][:mother][:foreigner_current_village]
      mother_foreigner_current_ta       = params[:person][:mother][:foreigner_current_ta]
      mother_home_country               = params[:person][:mother][:home_country]
      mother_foreigner_home_district    = params[:person][:mother][:foreigner_home_district]
      mother_foreigner_home_village     = params[:person][:mother][:foreigner_home_village]
      mother_foreigner_home_ta          = params[:person][:mother][:foreigner_home_ta]
      mother_estimated_dob	            =	params[:person][:mother][:birthdate_estimated]

    mother_mode_of_delivery           = params[:person][:mode_of_delivery]
    mother_level_of_education         = params[:person][:level_of_education]

    ################################ mother details (end) #######################################

    ########################### father details ########################################

      father_birthdate_estimated        = params[:person][:father][:birthdate_estimated]
      father_residential_country        = params[:person][:father][:residential_country]
      father_foreigner_current_district = params[:person][:father][:foreigner_current_district]
      father_foreigner_current_village  = params[:person][:father][:foreigner_current_village]
      father_foreigner_home_village     = params[:person][:father][:foreigner_home_village]
      father_foreigner_home_ta          = params[:person][:father][:foreigner_home_ta]
      father_lastname                   = params[:person][:father][:last_name]
      father_firstname                  = params[:person][:father][:first_name]
      father_middlename                 = params[:person][:father][:middle_name]
      father_birthdate                  = params[:person][:father][:birthdate]
      father_citizenship                = params[:person][:father][:citizenship]
      father_current_district           = params[:person][:father][:current_district]
      father_current_ta                 = params[:person][:father][:current_ta]
      father_current_village            = params[:person][:father][:current_village]
      father_home_district              = params[:person][:father][:home_district]
      father_home_ta                    = params[:person][:father][:home_ta]
      father_home_village               = params[:person][:father][:home_village]


    ######################### father details (end) #################################

    informant_last_name               = params[:person][:informant][:last_name]
    informant_first_name              = params[:person][:informant][:first_name]
    informant_middle_name             = params[:person][:informant][:middle_name]
    informant_relationship_to_child   = params[:person][:informant][:relationship_to_child]
    informant_current_district        = params[:person][:informant][:current_district]
    informant_current_ta              = params[:person][:informant][:current_ta]
    informant_current_village         = params[:person][:informant][:current_village]
    informant_addressline1            = params[:person][:informant][:addressline1]
    informant_addressline2            = params[:person][:informant][:addressline2]
    informant_phone_number            = params[:person][:informant][:phone_number]
    informant_form_signed             = params[:person][:form_signed]
    informant_same_as_mother          = params[:informant_same_as_mother]
    informant_same_as_father          = params[:informant_same_as_father]



    court_order_attached	            =	params[:person][:court_order_attached]
    parents_signed                    = params[:person][:parents_signed]

    parents_married_to_each_other	    =	params[:person][:parents_married_to_each_other]
    date_of_marriage                  = params[:person][:date_of_marriage]

    month_prenatal_care_started               = params[:month_prenatal_care_started]
    number_of_prenatal_visits                 = params[:number_of_prenatal_visits]
    gestation_at_birth                        = params[:gestation_at_birth]
    number_of_children_born_alive_inclusive   = params[:number_of_children_born_alive_inclusive].to_i rescue 1
    number_of_children_born_still_alive       = params[:number_of_children_born_still_alive].to_i rescue 1
    details_of_father_known 	                = params[:details_of_father_known]

    core_person = CorePerson.create(person_type_id: PersonType.where(name: 'Client').first.id)

    @person = Person.create(person_id: core_person.id,
      gender: gender.first, 
      birthdate: (birthdate.to_date rescue Date.today))

    person_name = PersonName.create(first_name: first_name, 
      middle_name: middle_name,
      last_name: last_name, person_id: core_person.id)

    PersonNameCode.create(person_name_id: person_name.id,
      first_name_code: first_name.soundex,
      last_name_code: last_name.soundex,
      middle_name_code: (middle_name.soundex rescue nil))

    @person_details = PersonBirthDetail.create(
      person_id:                                core_person.id,
      place_of_birth:                           (Location.find_by_name(place_of_birth).id rescue 1),
      birth_location_id:                        (Location.find_by_name(hospital_of_birth).id rescue 1),
      birth_weight:                             birth_weight,
      type_of_birth:                            (PersonTypeOfBirth.where(name: type_of_birth).first.id rescue 1),
      parents_married_to_each_other:            (parents_married_to_each_other == 'No' ? 0 : 1),
      date_of_marriage:                         (date_of_marriage.to_date rescue nil),
      gestation_at_birth:                       (gestation_at_birth.to_f rescue nil),
      number_of_prenatal_visits:                (number_of_prenatal_visits.to_i rescue nil),
      month_prenatal_care_started:              (month_prenatal_care_started.to_i rescue nil),
      mode_of_delivery_id:                      (ModeOfDelivery.where(name: mother_mode_of_delivery).first.id rescue 1),
      number_of_children_born_alive_inclusive:  (number_of_children_born_alive_inclusive),
      number_of_children_born_still_alive:      (number_of_children_born_still_alive),
      level_of_education_id:                    (LevelOfEducation.where(name: mother_level_of_education).first.id rescue 1),
      district_id_number:                       nil,     
      national_serial_number:                   nil,
      court_order_attached:                     (court_order_attached == 'No' ? 0 : 1),
      acknowledgement_of_receipt_date:          (acknowledgement_of_receipt_date.to_date rescue nil),
      facility_serial_number:                   nil,
      adoption_court_order:                     0
    )

    ################################### recording mother details (start) ###############################################

    if (parents_details_available == "Both" || parents_details_available == "Mother" || !mother_birthdate.blank?)

      core_person_mother = CorePerson.create(person_type_id: PersonType.where(name: 'Mother').first.id)

      person_mother = Person.create(person_id: core_person_mother.id,
          gender: "F",
          birthdate: (mother_birthdate.to_date rescue Date.today))

      person_name_mother = PersonName.create(first_name: mother_first_name,
          middle_name: mother_middle_name,
          last_name: mother_last_name, person_id: core_person_mother.id)

      PersonNameCode.create(person_name_id: person_name_mother.id,
          first_name_code: mother_first_name.soundex,
          last_name_code: mother_last_name.soundex,
          middle_name_code: (mother_middle_name.soundex rescue nil))

      PersonRelationship.create(person_a: core_person.id, person_b: core_person_mother.id,
          person_relationship_type_id: PersonRelationType.where(name: 'Child-Mother').first.id)


            PersonAddress.create(person_id: core_person_mother.id,
                           current_village: mother_foreigner_current_village,
                           current_village_other: "",
                           current_ta: mother_foreigner_current_ta,
                           current_ta_other: "",
                           current_district: mother_foreigner_current_district,
                           current_district_other: "",
                           home_village: mother_foreigner_home_village,
                           home_village_other: "",
                           home_ta: mother_foreigner_home_ta,
                           home_ta_other: "",
                           home_district: mother_foreigner_current_district,
                           home_district_other: "",
                           citizenship: Location.where(name: mother_residental_country).first.location_id,
                           residential_country: Location.where(name: mother_residental_country).first.location_id)
    end

    ################################### recording mother details (end)   ###############################################

    ################################### recording father details (start) ###############################################
    if(details_of_father_known == "Yes" || parents_details_available == "Both" ||
        parents_details_available == "Father" || !father_birthdate.blank?)

      core_person_father = CorePerson.create(person_type_id: PersonType.where(name: 'Father').first.id)

      person_father = Person.create(person_id: core_person_father.id,
          gender: "M",
          birthdate: (father_birthdate.to_date rescue Date.today))

      person_name_father = PersonName.create(first_name: father_firstname,
          middle_name: (father_middlename rescue nil),
          last_name: father_lastname, person_id: core_person_father.id)

      PersonNameCode.create(person_name_id: person_name_father.id,
          first_name_code: father_firstname.soundex,
          last_name_code: father_lastname.soundex,
          middle_name_code: (father_middlename.soundex rescue nil))

      PersonRelationship.create(person_a: core_person.id, person_b: core_person_father.id,
          person_relationship_type_id: PersonRelationType.where(name: 'Child-Father').first.id)

            PersonAddress.create(person_id: core_person_father.id,
                           current_village: father_foreigner_current_village,
                           current_village_other: "",
                           current_ta: father_foreigner_current_ta,
                           current_ta_other: "",
                           current_district: father_foreigner_current_district,
                           current_district_other: "",
                           home_village: father_foreigner_home_village,
                           home_village_other: "",
                           home_ta: father_foreigner_home_ta,
                           home_ta_other: "",
                           home_district: father_foreigner_current_district,
                           home_district_other: "",
                           citizenship: Location.where(name: father_residental_country).first.location_id,
                           residential_country: Location.where(name: father_residental_country).first.location_id)

    end
    ################################### recording father details (end)   ###############################################
    
    ################################### recording informant details (start) ############################################
    
    if (informant_same_as_mother == "Yes")

        PersonRelationship.create(person_a: core_person.id, person_b: core_person_mother.id,
        person_relationship_type_id: PersonRelationType.where(name: 'Child-Informant').first.id)
        informant_id = core_person_mother.id
    elsif (informant_same_as_father == "Yes")

        PersonRelationship.create(person_a: core_person.id, person_b: core_person_father.id,
        person_relationship_type_id: PersonRelationType.where(name: 'Child-Informant').first.id)
        informant_id = core_person_father.id
    else

      core_person_informant = CorePerson.create(person_type_id: PersonType.where(name: 'Informant').first.id)
      informant_id = core_person_informant.id
      person_informant = Person.create(person_id: core_person_informant.id,
          gender: "N/A",
          birthdate: ("1900-01-01".to_date))

      person_name_informant = PersonName.create(first_name: informant_first_name,
          middle_name: (informant_middle_name rescue nil),
          last_name: informant_last_name, person_id: core_person_informant.id)
      begin

        PersonNameCode.create(person_name_id: person_name_informant.id,
          first_name_code: informant_first_name.soundex,
          last_name_code: informant_last_name.soundex,
          middle_name_code: (informant_middle_name.soundex rescue nil))
      rescue

      end

      PersonRelationship.create(person_a: core_person.id, person_b: core_person_informant.id,
          person_relationship_type_id: PersonType.where(name: 'Informant').first.id)
       
    end

          PersonAddress.create(person_id: informant_id,
                           current_village: (Location.find_by_name(informant_current_village).id rescue 1),
                           current_village_other: "",
                           current_ta: (Location.find_by_name(informant_current_ta).id rescue 1),
                           current_ta_other: "",
                           current_district: (Location.find_by_name(informant_current_district).id rescue 1),
                           current_district_other: "",
                           home_village: (Location.find_by_name(informant_current_village).id rescue 1),
                           home_village_other: "",
                           home_ta: (Location.find_by_name(informant_current_ta).id rescue 1),
                           citizenship: Location.where(name: 'Malawi').first.location_id,
                           residential_country: Location.where(name: 'Malawi').first.location_id)

    ################################### recording informant details (end) ############################################
    #################################### person status record ####################################################
    
    if(SETTINGS["application_mode"]== "DC") 

      begin
        PersonRecordStatus.create(status_id: Status.where(name: 'DC Active').status.id, person_id: core_person.id)
      rescue 
        
      end
       
    else
       begin
         PersonRecordStatus.create(status_id: Status.where(name: 'DC Incomplete').status.id, person_id: core_person.id)
       rescue 
         
       end
     
    end


    #################################### Person status record (end) ##############################################
    ####################################### person address details ###############################################
        

    ########################################Person address details(end) ###############################################



    return @person
  end

end
