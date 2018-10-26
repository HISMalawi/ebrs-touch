class MassPerson < ActiveRecord::Base
  self.table_name = :mass_person
  self.primary_key = :mass_person_id

  def name
    "#{self.first_name} #{self.middle_name} #{self.last_name}".gsub(/\s+/, " ")
  end

  def mother_name
    "#{self.mother_first_name} #{self.mother_middle_name} #{self.mother_last_name}".gsub(/\s+/, " ")
  end

  def father_name
    "#{self.father_first_name} #{self.father_middle_name} #{self.father_last_name}".gsub(/\s+/, " ")
  end

  def informant_name
    "#{self.informant_first_name} #{self.informant_middle_name} #{self.informant_last_name}".gsub(/\s+/, " ")
  end

  def place_of_birth
    "#{self.village_of_birth}, #{self.ta_of_birth}, #{self.district_of_birth}".gsub(/\s+/, " ")
  end

  def self.dump

    data = MassPerson.new.attributes.keys.join(",") + "\n"
    upload_number   = MassPerson.find_by_sql(" SELECT MAX(upload_number) n FROM mass_person ").last['n'].to_i + 1
    upload_datetime = Time.now
    MassPerson.where(upload_status: "NOT UPLOADED").each do |person|
      data = data + person.attributes.values.join(",") + "\n"
      person.upload_status   =  "UPLOADED"
      person.upload_number   = upload_number
      person.upload_datetime = upload_datetime
      person.save
    end

    File.open("#{Rails.root}/dump.csv", "w"){|f|
      f.write(data)
    }

    return true
  end

  def self.offload_rollback
    File.read("#{Rails.root}/dump.csv").split("\n").each{|line|
      data = line.split(",")
      next if data.first.strip == "person_id"

      person                    = MassPerson.find(data[0])
      person.upload_status      = "NOT UPLOADED"
      person.upload_number      = nil
      person.upload_datetime    = nil
      person                    .save
    }

    File.open("#{Rails.root}/dump.csv", "w"){|f|
      f.write("")
    }

    return true
  end

  def self.format_person(hash, person_id=nil)

    person = {}
    person["id"] = person_id
    person["first_name"]= hash["first_name"] rescue ''
    person["last_name"] =  hash["last_name"] rescue ''
    person["middle_name"] = hash["middle_name"] rescue ''
    person["gender"] = hash["gender"]
    person["birthdate"]= hash["date_of_birth"].to_date.to_s
    person["birthdate_estimated"] = 0
    person["nationality"]=  hash["nationality"]
    person["place_of_birth"] = "Other"
    person["district"] = hash["district_created_at"]

    person["mother_first_name"]= hash["mother_first_name"]
    person["mother_last_name"] =  hash["mother_last_name"]
    person["mother_middle_name"] = hash["mother_middle_name"]

    person["mother_home_district"] = nil
    person["mother_home_ta"] = nil
    person["mother_home_village"] = nil

    person["mother_current_district"] = nil
    person["mother_current_ta"] = nil
    person["mother_current_village"] = nil

    person["father_first_name"]= hash["father_first_name"]
    person["father_last_name"] =  hash["father_last_name"]
    person["father_middle_name"] = hash["father_middle_name"]

    person["father_home_district"] = nil
    person["father_home_ta"] = nil
    person["father_home_village"] = nil

    person["father_current_district"] = nil
    person["father_current_ta"] = nil
    person["father_current_village"] = nil
    person
  end

  def map_to_ebrs_tables(upload_number, status)
    self.upload_datetime = Time.now
    self.upload_number = upload_number
    self.upload_status = "UPLOADED"

    ebrs_id = PersonService.create_mass_registration_person(self, status)
    if ebrs_id.present?
      self.save
    end

    ebrs_id
  end

  def self.load_mass_data

    columns = MassPerson.new.attributes.keys
    columns[0] = 'mass_person_id'

    File.read("#{Rails.root}/dump.csv").split("\n").each{|line|
      data = line.split(",")
      next if data.first.strip == "person_id"

      hash = {}
      data.each_with_index do |v, i|
          hash[columns[i]] = v
      end

      mass_person = MassPerson.new(hash)
      mass_person.mass_person_id = (MassPerson.count > 0 ? (MassPerson.last.mass_person_id + 1) : 1)
      mass_person.save
    }

    next_file = (`ls #{Rails.root}/mass_data`.split("\n").collect{|f| f.to_i}.max + 1).to_s
    File.rename "#{Rails.root}/dump.csv", "#{Rails.root}/mass_data/#{next_file}"

    return true
  end
end
