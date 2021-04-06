require 'rubygems'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/barcode/qr_code'
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
          r = [r, d].delete_if{|v| v.blank?}.join(", ")
        end
      elsif place_of_birth == "Home"
        l =  Location.find(self.birth_location_id) rescue ""
        d = Location.find(self.district_of_birth).name rescue l.district
	      r = [l.village, l.ta, d].delete_if{|v| v.blank?}.join(", ") # rescue ""
      else
        d = Location.find(self.district_of_birth).name rescue nil
        d = "" if d == "Other"
        r = [self.other_birth_location, d].delete_if{|v| v.blank?}.join(", ")
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
      nid_type_id = PersonIdentifierType.find_by_name("National ID Number").id

      PersonIdentifier.where(
          person_id: self.person_id,
          person_identifier_type_id: nid_type_id,
          voided: 0
      ).first.value rescue ""
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

=begin
    def self.generate_barcode(barcode, file_name, save_path)
      barcode = Barby::Code128B.new(barcode)
      file = File.open("#{save_path}/#{file_name}.png", "wb")
      file.write barcode.to_png(:height => 50, :xdim => 2)
      file.close
    end
=end

    def self.generate_barcode(barcode, file_name, save_path)

      if SETTINGS['enable_qr_code'] != true
        barcode = Barby::Code128B.new(barcode)
        file = File.open("#{save_path}/#{file_name}.png", "wb")
        file.write barcode.to_png(:height => 50, :xdim => 2)
        file.close
      else
        data = PersonService.qr_code_data(file_name)
        barcode = Barby::QrCode.new(data, level: :q, size: 15)
        file = File.open("#{save_path}/qr_#{file_name}.png", "wb")
        file.write barcode.to_png(:height => 50, :xdim => 2)
        file.close
      end
    end

	def generate_ben(year=Date.today.year)
		
		if !(ActiveRecord::Base.connection.table_exists? "ben_counter_#{year}")
			` bundle exec rails runner bin/init_ben_counter.rb #{year}`
		end 

		location = Location.find(SETTINGS['location_id'])
    district_code = location.code
		
		if self.district_id_number.blank? 
			counter = ActiveRecord::Base.connection.select_one("SELECT counter FROM ben_counter_#{year} WHERE person_id = #{self.person_id}").as_json['counter'] rescue nil
      if counter.blank?
				missing_ben = PersonBirthDetail.next_missing_ben(district_code, year)

				if !missing_ben.blank? #correct missing ben
          missing_person_id = ActiveRecord::Base.connection.select_one("SELECT person_id FROM ben_counter_#{year} WHERE counter = #{missing_ben.to_i};").as_json['person_id'] rescue nil
          if !missing_person_id.blank?
            missing_date_registered = ActiveRecord::Base.connection.select_one("SELECT created_at FROM ben_counter_#{year} WHERE counter = #{missing_ben.to_i};").as_json['created_at']
            corrected_missing_ben = "#{district_code}/#{missing_ben}/#{year}"

            corrected_pbd_1 = PersonBirthDetail.where(person_id: missing_person_id).last
            if corrected_pbd_1.blank?
              PersonService.force_sync(missing_person_id)
            end

            corrected_pbd = PersonBirthDetail.where(person_id: missing_person_id).last
            if !corrected_pbd.blank?
              corrected_pbd.district_id_number = corrected_missing_ben rescue nil
              corrected_pbd.date_registered = missing_date_registered.to_date rescue nil
              corrected_pbd.save rescue nil

              identifier = PersonIdentifier.where(person_id: missing_person_id, person_identifier_type_id: 2).last
              if identifier.blank?
                PersonIdentifier.new_identifier(self.person_id, 'Birth Entry Number', corrected_missing_ben)
              end
            end

            ActiveRecord::Base.connection.execute("INSERT INTO ben_counter_#{year}(person_id) VALUES (#{self.person_id});")
          else
            ActiveRecord::Base.connection.execute("INSERT INTO ben_counter_#{year}(counter, person_id) VALUES (#{missing_ben.to_i}, #{self.person_id});")
          end
          
				else
					ActiveRecord::Base.connection.execute("INSERT INTO ben_counter_#{year}(person_id) VALUES (#{self.person_id});")
				end 

				counter = ActiveRecord::Base.connection.select_one("SELECT counter FROM ben_counter_#{year} WHERE person_id = #{self.person_id};").as_json['counter']

			end 
			
			mid_number = counter.to_s.rjust(8,'0')
			ben   = "#{district_code}/#{mid_number}/#{year}"
			self.update_attributes(district_id_number: ben)
			self.update_attributes(date_registered: Date.today)
			PersonIdentifier.new_identifier(self.person_id, 'Birth Entry Number', ben)
      #PersonRecordStatus.new_record_state(self.person_id, "HQ-ACTIVE")
		end
		
		ben
	end 

 def calculate_check_digit(serial_number)

    number = serial_number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2!=parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end

    check_digit = (9 * sum) % 10

    return check_digit
  end

	def generate_facility_serial_number
		
		if self.facility_serial_number.blank?
			code = Location.find(SETTINGS['location_id']).code.squish
			left = "P5#{code}"
			from = left.length + 1
			length = 6

			last = (PersonBirthDetail.where(location_created_at: SETTINGS['location_id']).select(" MAX(SUBSTRING(facility_serial_number, #{from}, #{length})) AS last_num")[0]['last_num'] rescue 0 ).to_i
			num = last + 1
			num =  "%06d" % num

			checkdigit = calculate_check_digit(num)
			serial_number =  "#{left}#{num}#{checkdigit}"

			self.update_attributes(facility_serial_number: serial_number)
			PersonIdentifier.new_identifier(self.person_id, 'Facility Number', serial_number)	

			serial_number		
		end 
	end 
end
