require 'rubygems'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/rmagick_outputter'
require 'rqrcode'

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
        d = Location.find(self.district_of_birth).name rescue nil
        d = "" if d == "Other"

        if r == "Other"
          r = "#{self.other_birth_location}, #{d}"
        else
          r = "#{r}, #{d}"
        end
      elsif place_of_birth == "Home"
        l =  Location.find(self.birth_location_id) rescue ""
        r = "#{l.village}, #{l.ta}, #{l.district}" rescue ""
      else
        d = Location.find(self.district_of_birth).name rescue nil
        d = "" if d == "Other"
        r = "#{d}, #{self.other_birth_location}"
      end

      r
    end

    def brn
      n = self.national_serial_number
      if n.blank?
        type_id = PersonIdentifierType.where(:name => "Old Birth Registration Number").first.id
        return PersonIdentifier.where(person_id: self.person_id, :person_identifier_type_id => type_id, :voided => 0).last.value rescue nil
      end

      return nil if n.blank?
      gender = Person.find(self.person_id).gender == 'M' ? '2' : '1'
      n = n.to_s.rjust(10, '0')
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

      #First Name|Last Name|Birthdate|Gender|Mother First Name|Mother Last Name|Father First Name when Parants Married|
      #Father last name if parents married|Place of birth not nil, "" or "Other"

      if name.first_name.blank?
        return complete
      end

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

      if self.parents_married_to_each_other.to_s == '1'

        if (father_person.person_names.last.first_name.blank? rescue true)
          return complete
        end

        if (father_person.person_names.last.last_name.blank? rescue true)
          return complete
        end
      end

      if [nil, "", "Other"].include?(self.birthplace)
        return complete
      end

      return true
    end

    def national_id
      PersonIdentifier.find_by_person_id_and_person_identifier_type_id(self.person_id,
      PersonIdentifierType.find_by_name("National ID Number").id).value rescue ""
    end

    def self.next_missing_brn
      found    = ActiveRecord::Base.connection.select_all(" SELECT national_serial_number FROM person_birth_details WHERE national_serial_number IS NOT NULL").collect{|h| h.values.first.to_i}
      return nil if found.blank?

      missing = []
      missing  = Array(found.min.to_i .. found.max.to_i) - found if found.length > 0

      brn = nil
      if missing.length > 0
        brn    = missing.first
      end

      brn
    end

    def self.next_missing_ben(district_code, year)
      a = PersonBirthDetail.where("district_id_number LIKE '#{district_code}/%/#{year}' ").map(&:district_id_number)
      a = a.collect{|bn| bn.split("/")[1].to_i}.sort
      return nil if a.blank?

      missing = Array(a.first .. a.last) - a

      mid_number = nil
      if missing.length > 0
        mid_number = missing.first.to_s.rjust(8,'0')
      end
      mid_number
    end

    def self.missing_bens(district_code, year)
      a = PersonBirthDetail.where("district_id_number LIKE '#{district_code}/%/#{year}' ").map(&:district_id_number)
      a = a.collect{|bn| bn.split("/")[1].to_i}.sort

      return [] if a.blank?

      Array(a.first .. a.last) - a
    end

    def self.missing_brns
      found    = ActiveRecord::Base.connection.select_all(" SELECT national_serial_number FROM person_birth_details WHERE national_serial_number IS NOT NULL").collect{|h| h.values.first.to_i}
      return [] if found.blank?

      Array(found.min.to_i .. found.max.to_i) - found
    end

    def self.generate_barcode(barcode, file_name, save_path)
      barcode = Barby::Code128B.new(barcode)
      file = File.open("#{save_path}/#{file_name}.png", "wb")
      file.write barcode.to_png(:height => 50, :xdim => 2)
      file.close
    end
end
