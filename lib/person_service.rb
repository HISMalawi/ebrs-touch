module PersonService
	require 'bean'
	require 'json'

  def self.create_record(params)
    first_name 			                  = params[:person][:first_name]
    last_name 			                  = params[:person][:last_name]
    middle_name 		                  = params[:person][:middle_name]
    place_of_birth		                = params[:person][:place_of_birth]
    hospital_of_birth	                =	params[:person][:hospital_of_birth]
    birth_district		                =	params[:person][:birth_district]
    birth_weight		                  = params[:person][:birth_weight]
    acknowledgement_of_receipt_date	  = params[:person][:acknowledgement_of_receipt_date]

    gender 				      	            = params[:child][:gender]
    home_address_same_as_physical     = params[:child][:home_address_same_as_physical]
    details_of_father_known 	        = params[:child][:details_of_father_known]
    same_address_with_mother	        = params[:child][:same_address_with_mother]
    registration_type 	              = params[:child][:registration_type]
    copy_mother_name                  = params[:child][:copy_mother_name]
    type_of_birth		                  = params[:child][:type_of_birth]
    mother_last_name 	                =	params[:child][:mother][:last_name]
    mother_first_name	                =	params[:child][:mother][:first_name]
    mother_middle_name	              =	params[:child][:mother][:middle_name]
    mother_birthdate	                =	params[:child][:mother][:birthdate]
    mother_citizenship	              =	params[:child][:mother][:citizenship]
    mother_residental_country         = params[:child][:mother][:residential_country]
    mother_foreigner_current_district = params[:child][:mother][:foreigner_current_district]
    mother_foreigner_current_village  = params[:child][:mother][:foreigner_current_village]
    mother_foreigner_current_ta       = params[:child][:mother][:foreigner_current_ta]
    mother_home_country               = params[:child][:mother][:home_country]
    mother_foreigner_home_district    = params[:child][:mother][:foreigner_home_district]
    mother_foreigner_home_village     = params[:child][:mother][:foreigner_home_village]
    mother_foreigner_home_ta          = params[:child][:mother][:foreigner_home_ta]
    mother_mode_of_delivery           = params[:child][:mode_of_delivery]
    mother_level_of_education         = params[:child][:level_of_education]
    
    father_birthdate_estimated        = params[:child][:father][:birthdate_estimated]
    father_residential_country        = params[:child][:father][:residential_country]

    informant_last_name               = params[:child][:informant][:last_name]
    informant_first_name              = params[:child][:informant][:first_name]
    informant_middle_name             = params[:child][:informant][:middle_name]
    informant_relationship_to_child   = params[:child][:informant][:relationship_to_child]
    informant_current_district        = params[:child][:informant][:current_district]
    informant_current_ta              = params[:child][:informant][:current_ta]
    informant_current_village         = params[:child][:informant][:current_village]
    informant_addressline1            = params[:child][:informant][:addressline1]
    informant_addressline2            = params[:child][:informant][:addressline2]
    informant_phone_number            = params[:child][:informant][:phone_number]
    informant_form_signed             = params[:child][:informant][:form_signed]
    informant_same_as_mother          = params[:child][:informant][:informant_same_as_mother]


    mother_estimated_dob	            =	params[:child][:mother][:birthdate_estimated]
    court_order_attached	            =	params[:child][:court_order_attached]

    parents_married_to_each_other	    =	params[:child][:parents_married_to_each_other]

  
    core_person = CorePerson.create(person_type_id: PersonType.where(name: 'Client').first.id)

    person = Person.create(person_id: core_person.id, 
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
      place_of_birth:                           1,
      birth_location_id:                        (Location.last.id),
      birth_weight:                             birth_weight,
      type_of_birth:                            (PersonTypeOfBirth.where(name: type_of_birth).first.id rescue 1),
      parents_married_to_each_other:            (parents_married_to_each_other == 'No' ? 0 : 1),
      date_of_marriage:                         (date_of_marriage.to_date rescue nil),
      gestation_at_birth:                       (gestation_at_birth.to_f rescue nil),
      number_of_prenatal_visits:                (number_of_prenatal_visits.to_i rescue nil),
      month_prenatal_care_started:              (month_prenatal_care_started.to_i rescue nil),
      mode_of_delivery_id:                      (ModeOfDelivery.where(name: mother_mode_of_delivery).first.id rescue 1),
      number_of_children_born_alive_inclusive:  (number_of_children_born_alive_inclusive rescue 1),
      number_of_children_born_still_alive:      (number_of_children_born_still_alive rescue 1),
      level_of_education_id:                    (LevelOfEducation.where(name: mother_level_of_education).first.id rescue 1),
      district_id_number:                       nil,     
      national_serial_number:                   nil,
      court_order_attached:                     (court_order_attached == 'No' ? 0 : 1),
      acknowledgement_of_receipt_date:          (acknowledgement_of_receipt_date.to_date rescue nil),
      facility_serial_number:                   nil,
      adoption_court_order:                     0
    )
    
    raise "........... #{mother_residental_country}" 
  end

end
