require 'couchrest_model'

class PersonBirthDetailsCouchdb < CouchRest::Model::Base

  #Demographics details
  property :first_name,                                 String
  property :middle_name,                                String
  property :last_name,                                  String
  property :gender,                                     String
  property :birthdate,                                  Date
  property :birthdate_estimated,                        TrueClass, default: false 

  #Birth details
  property  :place_of_birth,                            Integer
  property  :birth_location_id,                         Integer
  property  :other_birth_location,                      String
  property  :birth_weight,                              String
  property  :type_of_birth,                             Integer
  property  :parents_married_to_each_other,             TrueClass, default: false
  property  :date_of_marriage,                          Date
  property  :gestation_at_birth,                        Integer
  property  :number_of_prenatal_visits,                 Integer
  property  :month_prenatal_care_started,               Integer
  property  :mode_of_delivery_id,                       Integer
  property  :number_of_children_born_alive_inclusive,   Integer
  property  :number_of_children_born_still_alive,       Integer
  property  :level_of_education_id,                     Integer
  property  :district_id_number,                        String
  property  :national_serial_number,                    Integer
  property  :court_order_attached,                      TrueClass, default: false
  property  :acknowledgement_of_receipt_date,           Date
  property  :facility_serial_number,                    String
  property  :adoption_court_order,                      TrueClass, default: false
  property  :birth_registration_type_id,                Integer
  property  :location_created_at,                       Integer
  
  #Person's other details
  property  :old_district_id_number,                    String
  property  :old_national_serial_number,                Integer
  property  :nrb_national_id,                           String
  property  :patient_national_id,                       String
  property  :person_home_village_id,                    Integer
  property  :person_current_village_id,                 Integer
  property  :person_address_one,                        String  
  property  :person_address_two,                        String  

  #Mother details
  property  :mother_first_name,                         String  
  property  :mother_middle_name,                        String  
  property  :mother_last_name,                          String  
  property  :mother_home_village_id,                    Integer
  property  :mother_current_village_id,                 Integer
  property  :mother_address_one,                        String  
  property  :mother_address_two,                        String  

  #Mother details
  property  :father_first_name,                         String  
  property  :father_middle_name,                        String  
  property  :father_last_name,                          String  
  property  :father_home_village_id,                    Integer
  property  :father_current_village_id,                 Integer
  property  :father_address_one,                        String  
  property  :father_address_two,                        String  

  #Informant details
  property  :informant_first_name,                      String  
  property  :informant_middle_name,                     String  
  property  :informant_last_name,                       String  
  property  :informant_relationship,                    String  
  property  :informant_phone_number,                    String  
  property  :informant_address_one,                     String  
  property  :informant_address_two,                     String  


  #record validity status
  property  :voided_by,                                 Integer
  property  :voided_date,                               String
  property  :voided,                                    TrueClass, default: false

  #record creation/updated time details
  property  :created_at,                                Time
  property  :updated_at,                                Time

  validates_uniqueness_of :district_id_number
  validates_uniqueness_of :national_serial_number


  def self.create_record(core_person)
    ActiveRecord::Base.transaction do
      person = core_person.person
      given_names = person.person_names.last
      birth_detail = core_person.person_birth_detail

      record = self.create(
        first_name:                                     given_names.first_name ,
        middle_name:                                    given_names.middle_name,
        last_name:                                      given_names.last_name,
        gender:                                         person.gender,
        birthdate:                                      person.birthdate,
        birthdate_estimated:                            person.birthdate_estimated,

        place_of_birth:                                 birth_detail.place_of_birth,
        birth_location_id:                              birth_detail.birth_location_id,
        other_birth_location:                           birth_detail.other_birth_location,
        birth_weight:                                   birth_detail.birth_weight,
        type_of_birth:                                  birth_detail.type_of_birth,
        parents_married_to_each_other:                  birth_detail.parents_married_to_each_other,
        date_of_marriage:                               birth_detail.date_of_marriage,
        gestation_at_birth:                             birth_detail.gestation_at_birth,
        number_of_prenatal_visits:                      birth_detail.number_of_prenatal_visits,
        month_prenatal_care_started:                    birth_detail.month_prenatal_care_started,
        mode_of_delivery_id:                            birth_detail.mode_of_delivery_id,
        number_of_children_born_alive_inclusive:        birth_detail.number_of_children_born_alive_inclusive,
        number_of_children_born_still_alive:            birth_detail.number_of_children_born_still_alive,
        level_of_education_id:                          birth_detail.level_of_education_id,
        district_id_number:                             birth_detail.district_id_number,
        national_serial_number:                         birth_detail.national_serial_number,
        court_order_attached:                           birth_detail.court_order_attached,
        acknowledgement_of_receipt_date:                birth_detail.acknowledgement_of_receipt_date,
        facility_serial_number:                         birth_detail.facility_serial_number,
        adoption_court_order:                           birth_detail.adoption_court_order,
        birth_registration_type_id:                     birth_detail.birth_registration_type_id,
        location_created_at:                            birth_detail.location_created_at,
        old_district_id_number:                         (get_person_identifier(core_person.id, "Old district ID number")),
        old_national_serial_number:                     (get_person_identifier(core_person.id, "Old national serial number")),
        nrb_national_id:                                (get_person_identifier(core_person.id, "NRB national ID")),
        patient_national_id:                            (get_person_identifier(core_person.id, "National patient ID")),                  
        person_home_village_id:                         birth_detail.person_home_village_id,
        person_current_village_id:                      birth_detail.person_current_village_id,
        person_address_one:                             birth_detail.person_address_one,
        person_address_two:                             birth_detail.person_address_two)
        
      
      person_relationship_type = PersonRelationshipType.where(name: 'Mother').first
      mother = CorePerson.where("person_a = ?",  
        core_person.id).joins("INNER JOIN person_relationship r 
        ON r.person_b = core_person.person_id
        AND r.person_relationship_type_id = #{person_relationship_type.id}")

      person_relationship_type = PersonRelationshipType.where(name: 'Father').first

        relationships = PersonRelationship.where(person_a: core_person.id)
        (relationships || []).each do |r|
          relation        = CorePerson.where(person_id: r.person_b).first
          relation_person = core_person.person
          given_names     = person.person_names.last

          if r.person_relationship.name.match(/mother/i)
            record.update_attributes(
              mother_first_name:          given_names.first_name                             ,
              mother_middle_name:         given_names.middle_name,
              mother_last_name:           given_names.last_name,
              mother_home_village_id:     birth_detail.mother_home_village_id,
              mother_current_village_id:  birth_detail.mother_current_village_id,
              mother_address_two:         birth_detail.mother_address_two
            )
          elsif r.person_relationship.name.match(/father/i)
            record.update_attributes(
              father_first_name:          given_names.first_name,      
              father_middle_name:         given_names.middle_name,
              father_last_name:           given_names.last_name,
              father_home_village_id:     birth_detail.father_home_village_id,
              father_current_village_id:  birth_detail.father_current_village_id,
              father_address_one:         birth_detail.father_address_one,
              father_address_two:         birth_detail.father_address_two
            )
          elsif r.person_relationship.name.match(/father/i)
            record.update_attributes(
              informant_first_name:       given_names.first_name,
              informant_middle_name:      given_names.middle_name,
              informant_last_name:        given_names.last_name,
              informant_relationship:     birth_detail.informant_relationship,
              informant_phone_number:     birth_detail.informant_phone_number,
              informant_address_one:      birth_detail.informant_address_one,
              informant_address_two:      birth_detail.informant_address_two
            )
          end
        end


        return record.id
    end

  end

end
