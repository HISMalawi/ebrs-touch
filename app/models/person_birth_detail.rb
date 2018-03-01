class PersonBirthDetail < ActiveRecord::Base
    self.table_name = :person_birth_details
    self.primary_key = :person_birth_details_id
    include EbrsAttribute

    belongs_to :core_person, foreign_key: "person_id"
    has_one :location, foreign_key: "location_id"
    has_one :level_of_education, foreign_key: "level_of_education_id"
    has_one :guardianship, foreign_key: ":guardianship_id"
    has_one :mode_of_delivery, foreign_key: "mode_of_delivery_id"
    has_one :birth_registration_type, foreign_key: "birth_registration_type_id"
    has_one :person_type_of_birth, foreign_key: "person_type_of_birth_id"
    before_create :set_level

    def set_level
      self.level = SETTINGS['application_mode']
    end

    def birth_type
      PersonTypeOfBirth.find(self.type_of_birth)
    end

    def reg_type
      BirthRegistrationType.find(self.birth_registration_type_id)
    end

    def mode_of_delivery
      ModeOfDelivery.find(self.mode_of_delivery_id)
    end

    def level_of_education
      LevelOfEducation.find(self.level_of_education_id).name
    end

    def birthplace
      place_of_birth = Location.find(self.place_of_birth).name
      r = nil
      if place_of_birth == "Hospital"
        r = Location.find(self.birth_location_id).name
      elsif place_of_birth == "Home"
        l =  Location.find(self.birth_location_id) rescue ""
        r = "#{r.village}, #{l.ta}, #{r.district}" rescue ""
      else
        d = Location.find(self.district_of_birth).name rescue nil
        d = "" if d == "Other"
        r = "#{d}, #{self.other_birth_location}"
      end

      r
    end

    def brn
      n = self.national_serial_number
      return nil if n.blank?
      gender = Person.find(self.person_id).gender == 'M' ? '2' : '1'
      n = n.to_s.rjust(12, '0')
      n.insert(n.length/2, gender)
    end

    def ben
      self.district_id_number
    end

    def fsn
      self.facility_serial_number
    end

    def birth_place
      Location.find(self.place_of_birth)
    end

    def record_complete?()

      complete = false
      name = PersonName.where(person_id: self.person_id).last
      person = Person.where(person_id: self.person_id).last
      mother_person = person.mother_all
      father_person = person.father_all
      if name.last_name.blank?
        return complete
      end

      if person.birthdate.blank?
        return complete
      end

      if person.gender.blank?
        return complete
      end

      if (mother_person.person_names.last.first_name.blank? rescue true)
        return complete
      end

      if (mother_person.person_names.last.last_name.blank? rescue true)
        return complete
      end

      if (mother_person.birthdate.blank? rescue true)
        return complete
      end

      if self.parents_married_to_each_other.to_s == '1'

        if (father_person.person_names.last.first_name.blank? rescue true)
          return complete
        end

        if (father_person.person_names.last.last_name.blank? rescue true)
          return complete
        end
      end

      return true
    end
end
