module PersonService
	require 'bean'
	require 'json'

  def self.create_record(params)
    


    adoption_court_order              = params[:person][:adoption_court_order] rescue nil
    desig              = params[:person][:informant][:designation] rescue nil
    birth_place_details_available     = params[:birth_place_details_available]
    parents_details_available         = params[:parents_details_available]
    biological_parents                = params[:biological_parents]
    foster_parents                    = params[:foster_parents]

    first_name 			                  = params[:person][:first_name]
    last_name 			                  = params[:person][:last_name]

    #raise last_name.inspect

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

 
      informant_same_as_mother          = params[:person][:informant][:informant_same_as_mother]
      informant_same_as_father          = params[:person][:informant][:informant_same_as_father]

      father_birthdate_estimated        = params[:person][:father][:birthdate_estimated]
      father_residential_country        = params[:person][:father][:residential_country]
      father_foreigner_current_district = params[:person][:father][:foreigner_current_district]
      father_foreigner_current_village  = params[:person][:father][:foreigner_current_village]
      father_foreigner_current_ta       = params[:person][:father][:foreigner_current_ta]
      father_residental_country         = params[:person][:father][:residential_country]
      father_foreigner_home_village     = params[:person][:father][:foreigner_home_village]
      father_foreigner_home_ta          = params[:person][:father][:foreigner_home_ta]
      father_last_name                   = params[:person][:father][:last_name]
      father_first_name                  = params[:person][:father][:first_name]
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



     #raise informant_current_ta.inspect

    court_order_attached	            =	params[:person][:court_order_attached]
    parents_signed                    = params[:person][:parents_signed]

    parents_married_to_each_other	    =	params[:person][:parents_married_to_each_other]

    month_prenatal_care_started               = params[:month_prenatal_care_started]
    number_of_prenatal_visits                 = params[:number_of_prenatal_visits]
    gestation_at_birth                        = params[:gestation_at_birth]
    number_of_children_born_alive_inclusive   = params[:number_of_children_born_alive_inclusive].to_i rescue 1
    number_of_children_born_still_alive       = params[:number_of_children_born_still_alive].to_i rescue 1
    details_of_father_known 	                = params[:details_of_father_known]

    
  ################################################## Recording client details #####################################
 
 if SETTINGS["application_mode"] == "FC"



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

       
  
    PersonBirthDetail.create(
      person_id:                                core_person.id,
      birth_registration_type_id:               SETTINGS['application_mode'] =='FC' ? BirthRegistrationType.where(name: 'Normal').first.birth_registration_type_id : BirthRegistrationType.where(name: params[:registration_type]).first.birth_registration_type_id,
      place_of_birth:                           Location.where(location_id: SETTINGS['location_id']).first.location_id,
      birth_location_id:                        Location.where(location_id: SETTINGS['location_id']).first.location_id,
      birth_weight:                             birth_weight,
      type_of_birth:                            self.is_num?(type_of_birth) == true ? PersonTypeOfBirth.where(person_type_of_birth_id: type_of_birth).first.id : PersonTypeOfBirth.where(name: type_of_birth).first.id,
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
      adoption_court_order:                     0,

    )



############################################## Client details end ####################################################


############################################# recording mother details ##############################################
 
 if !mother_first_name.blank?

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
                    person_relationship_type_id: PersonRelationType.where(name: 'Mother').first.id)


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
                    residential_country: Location.where(name: mother_residental_country).first.location_id) rescue nil


    
end
#############################################################################################################################


########################################## Recording father details #################################################
    if !father_first_name.blank?



      core_person_father = CorePerson.create(person_type_id: PersonType.where(name: 'Father').first.id)

            person_father = Person.create(person_id: core_person_father.id,
                gender: "M",
                birthdate: (father_birthdate.to_date rescue Date.today))

            person_name_father = PersonName.create(first_name: father_first_name,
                middle_name: (father_middlename rescue nil),
                last_name: father_last_name, person_id: core_person_father.id)

            PersonNameCode.create(person_name_id: person_name_father.id,
                first_name_code: father_first_name.soundex,
                last_name_code: father_last_name.soundex,
                middle_name_code: (father_middlename.soundex rescue nil))

            PersonRelationship.create(person_a: core_person.id, person_b: core_person_father.id,
                person_relationship_type_id: PersonRelationType.where(name: 'Father').first.id)

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
                                 residential_country: Location.where(name: father_residental_country).first.location_id) rescue nil


          
    end
   ############################################# father details end ###########################################################

   ######################################### Recording informant details #############################################
    
    if (informant_same_as_mother == "Yes")

       

              PersonRelationship.create(person_a: core_person.id, person_b: core_person_mother.id,
              person_relationship_type_id: PersonRelationType.where(name: 'Mother').first.id)
              informant_id = core_person_mother.id

      PersonAddress.create(person_id: core_person_mother.id,
                                 current_village: Location.where(name: mother_current_village).first.location_id,
                                 current_village_other: "",
                                 current_ta: Location.where(name: mother_current_ta).first.location_id,
                                 current_ta_other: "",
                                 current_district: Location.find_by_name(mother_current_district).location_id,
                                 current_district_other: "",
                                 home_village: Location.where(name:mother_current_village).first.location_id,
                                 home_village_other: "",
                                 home_ta: Location.where(name:mother_current_ta).first.location_id,
                                 citizenship: Location.where(name: 'Malawi').first.location_id,
                                 residential_country: Location.where(name: 'Malawi').first.location_id)
              
    elsif (informant_same_as_father == "Yes")

              PersonRelationship.create(person_a: core_person.id, person_b: core_person_father.id,
              person_relationship_type_id: PersonRelationType.where(name: 'Father').first.id)
              informant_id = core_person_father.id

          PersonAddress.create(person_id: core_person_father.id,
                                 current_village: Location.where(name: father_current_village).first.location_id,
                                 current_village_other: "",
                                 current_ta: Location.where(name: father_current_ta).first.location_id,
                                 current_ta_other: "",
                                 current_district: Location.find_by_name(father_current_district).location_id,
                                 current_district_other: "",
                                 home_village: Location.where(name:father_current_village).first.location_id,
                                 home_village_other: "",
                                 home_ta: Location.where(name:father_current_ta).first.location_id,
                                 citizenship: Location.where(name: 'Malawi').first.location_id,
                                 residential_country: Location.where(name: 'Malawi').first.location_id)

   elsif !informant_first_name.blank?

         

            core_person_informant = CorePerson.create(person_type_id: PersonType.where(name: 'Informant').first.id)
            informant_id = core_person_informant.id
            person_informant = Person.create(person_id: core_person_informant.id,
                gender: "N/A",
                birthdate: ("1900-01-01".to_date))

            #raise informant_first_name.inspect

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

            PersonAddress.create(person_id: core_person_informant.id,
                                 current_village: Location.where(name: informant_current_village).first.location_id,
                                 current_village_other: "",
                                 current_ta: Location.where(name: informant_current_ta).first.location_id,
                                 current_ta_other: "",
                                 current_district: Location.find_by_name(informant_current_district).location_id,
                                 current_district_other: "",
                                 home_village: Location.where(name:informant_current_village).first.location_id,
                                 home_village_other: "",
                                 home_ta: Location.where(name:informant_current_ta).first.location_id,
                                 citizenship: Location.where(name: 'Malawi').first.location_id,
                                 residential_country: Location.where(name: 'Malawi').first.location_id)

   end
               
   ############################################## Informant details end #############################################
   
   ############################################### Person record Status ###############################################

    PersonRecordStatus.create(status_id: Status.where(name: 'DC-Complete').last.id, person_id: core_person.id)
   
   ####################################################################################################################  

elsif SETTINGS["application_mode"] == "DC"

  ################################################### Client details ############################################

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
 
     raise params.inspect

     loc_tag_id = LocationTag.where(name: place_of_birth).first.location_tag_id
     loc_id = LocationTagMap.where(location_tag_id: loc_tag_id).first.location_id

     params

    PersonBirthDetail.create(
      person_id:                                core_person.id,
      birth_registration_type_id:               BirthRegistrationType.where(name: params[:relationship]).first.birth_registration_type_id,
      place_of_birth:                           Location.where(location_id: loc_id).first.location_id,
      birth_location_id:                        Location.where(name: hospital_of_birth).first.location_id,
      birth_weight:                             birth_weight,
      type_of_birth:                            self.is_num?(type_of_birth) == true ? PersonTypeOfBirth.where(person_type_of_birth_id: type_of_birth).first.id : PersonTypeOfBirth.where(name: type_of_birth).first.id,
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
      adoption_court_order:                     0,

    )

############################################## Client details end ####################################################

######################################### recording mother details (start) ###############################################
           
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
                person_relationship_type_id: PersonRelationType.where(name: 'Mother').first.id)


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
                                 residential_country: Location.where(name: mother_residental_country).first.location_id) rescue nil
          end

############################################ recording mother details (end)   ###############################################

########################################### recording father details (start) ###############################################

          if(details_of_father_known == "Yes" || parents_details_available == "Both" ||
              parents_details_available == "Father" || !father_birthdate.blank?)

            core_person_father = CorePerson.create(person_type_id: PersonType.where(name: 'Father').first.id)

            person_father = Person.create(person_id: core_person_father.id,
                gender: "M",
                birthdate: (father_birthdate.to_date rescue Date.today))

            person_name_father = PersonName.create(first_name: father_first_name,
                middle_name: (father_middlename rescue nil),
                last_name: father_last_name, person_id: core_person_father.id)

            PersonNameCode.create(person_name_id: person_name_father.id,
                first_name_code: father_first_name.soundex,
                last_name_code: father_last_name.soundex,
                middle_name_code: (father_middlename.soundex rescue nil))

            PersonRelationship.create(person_a: core_person.id, person_b: core_person_father.id,
                person_relationship_type_id: PersonRelationType.where(name: 'Father').first.id)

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
                                 residential_country: Location.where(name: father_residental_country).first.location_id) rescue nil

          end

############################################# recording father details (end)   ###############################################
          
######################################### Recording informant details #############################################
    
    if (informant_same_as_mother == "Yes")

       

          PersonRelationship.create(person_a: core_person.id, person_b: core_person_mother.id,
              person_relationship_type_id: PersonRelationType.where(name: 'Mother').first.id)
              informant_id = core_person_mother.id

          PersonAddress.create(person_id: core_person_mother.id,
                                     current_village: Location.where(name: mother_current_village).first.location_id,
                                     current_village_other: "",
                                     current_ta: Location.where(name: mother_current_ta).first.location_id,
                                     current_ta_other: "",
                                     current_district: Location.find_by_name(mother_current_district).location_id,
                                     current_district_other: "",
                                     home_village: Location.where(name:mother_current_village).first.location_id,
                                     home_village_other: "",
                                     home_ta: Location.where(name:mother_current_ta).first.location_id,
                                     citizenship: Location.where(name: 'Malawi').first.location_id,
                                     residential_country: Location.where(name: 'Malawi').first.location_id)
              
    elsif (informant_same_as_father == "Yes")

          PersonRelationship.create(person_a: core_person.id, person_b: core_person_father.id,
              person_relationship_type_id: PersonRelationType.where(name: 'Father').first.id)
              informant_id = core_person_father.id

          PersonAddress.create(person_id: core_person_father.id,
                                 current_village: Location.where(name: father_current_village).first.location_id,
                                 current_village_other: "",
                                 current_ta: Location.where(name: father_current_ta).first.location_id,
                                 current_ta_other: "",
                                 current_district: Location.find_by_name(father_current_district).location_id,
                                 current_district_other: "",
                                 home_village: Location.where(name:father_current_village).first.location_id,
                                 home_village_other: "",
                                 home_ta: Location.where(name:father_current_ta).first.location_id,
                                 citizenship: Location.where(name: 'Malawi').first.location_id,
                                 residential_country: Location.where(name: 'Malawi').first.location_id)

   elsif !informant_first_name.blank?

         

            core_person_informant = CorePerson.create(person_type_id: PersonType.where(name: 'Informant').first.id)
            informant_id = core_person_informant.id
            person_informant = Person.create(person_id: core_person_informant.id,
                gender: "N/A",
                birthdate: ("1900-01-01".to_date))

            #raise informant_first_name.inspect

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

            PersonAddress.create(person_id: core_person_informant.id,
                                 current_village: Location.where(name: informant_current_village).first.location_id,
                                 current_village_other: "",
                                 current_ta: Location.where(name: informant_current_ta).first.location_id,
                                 current_ta_other: "",
                                 current_district: Location.find_by_name(informant_current_district).location_id,
                                 current_district_other: "",
                                 home_village: Location.where(name:informant_current_village).first.location_id,
                                 home_village_other: "",
                                 home_ta: Location.where(name:informant_current_ta).first.location_id,
                                 citizenship: Location.where(name: 'Malawi').first.location_id,
                                 residential_country: Location.where(name: 'Malawi').first.location_id)

   end
               
  ############################################## Informant details end #############################################
  ############################################## person status record ####################################################
          
          
               PersonRecordStatus.create(status_id: Status.where(name: 'DC-Active').last.id, person_id: core_person.id)
    
        
  ############################################# Person status record (end) ##############################################
  ############################################### person address details ###############################################
              

  #############################################Person address details(end) ###############################################
   
 end
     
    return @person

end

  def self.mother(person_id)
    result = nil
    relationship_type = PersonRelationType.find_by_name("Mother")
    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last
    if !relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.is_num?(val)

    #checks if the val is numeric or string
      !!Integer(val)
    rescue ArgumentError, TypeError
      false

  end

  def self.father(person_id)
    result = nil
    relationship_type = PersonRelationType.find_by_name("Father")
    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last
    if !relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.query_for_display(states)
    state_ids = states.collect{|s| Status.find_by_name(s).id} + [-1]
    person_type = PersonType.where(name: 'Client').first

    main = Person.find_by_sql(
          "SELECT n.*, prs.status_id FROM person p
            INNER JOIN core_person cp ON p.person_id = cp.person_id
            INNER JOIN person_name n ON p.person_id = n.person_id
            INNER JOIN person_record_statuses prs ON p.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
            INNER JOIN person_birth_details pbd ON p.person_id = pbd.person_id
          WHERE prs.status_id IN (#{state_ids.join(', ')})
            AND cp.person_type_id = #{person_type.id}
          GROUP BY p.person_id
          ORDER BY p.updated_at DESC
           "
    )

    results = []
    main.each do |data|
      mother = self.mother(data.person_id)
      father = self.father(data.person_id)

      name          = ("#{data['first_name']} #{data['middle_name']} #{data['last_name']}").gsub(/\s+/, ' ')
      mother_name   = ("#{mother['first_name']} #{mother['middle_name']} #{mother['last_name']}").gsub(/\s+/, ' ')
      father_name   = ("#{father['first_name']} #{father['middle_name']} #{father['last_name']}").gsub(/\s+/, ' ')

      results << {
          'id' => data.person_id,
          'name'        => name,
          'father_name'       => father_name,
          'mother_name'       => mother_name,
          'status'            => Status.find(data.status_id).name, #.gsub(/DC\-|FC\-|HQ\-/, '')
          'date_of_reporting' => data['created_at'].to_date.strftime("%d/%b/%Y"),
      }
    end

    results
  end

  def self.record_complete?(child)
      name = PersonName.find_by_person_id(child.id)
      pbs = PersonBirthDetail.find_by_person_id(child.id) rescue nil
      birth_type = BirthRegistrationType.find(pbs.birth_registration_type_id).name rescue nil
      mother_name = self.mother(child.id)
      father_name = self.father(child.id)
      complete = false

      return false if pbs.blank?

      if name.first_name.blank?
        return complete
      end

      if name.last_name.blank?
        return complete
      end

      if (child.birthdate.to_date.blank? rescue true)
          return complete
      end

      if child.gender.blank? || child.gender == 'N/A'
        return complete
      end

      if birth_type.downcase == "normal"

        if mother_name.first_name.blank?
          return complete
        end

        if mother_name.last_name.blank?
          return complete
        end

      end

      if pbs.parents_married_to_each_other.to_s == '1'
        if father_name.first_name.blank?
          return complete
        end

        if father_name.last_name.blank?
          return complete
        end
      end

      return true

  end

end
