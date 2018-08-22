$counter = 0
$codes = JSON.parse(File.read("#{Rails.root}/db/code2country.json"))

PersonTypeOfBirth.create(
    name: "Unknown"
) if PersonTypeOfBirth.where(name: "Unknown").blank?

ModeOfDelivery.create(
    name: "Unknown"
) if ModeOfDelivery.where(name: "Unknown").blank?

LevelOfEducation.create(
    name: "Unknown"
) if LevelOfEducation.where(name: "Unknown").blank?

def assign_next_ben(person_id, district_code)

  $counter = $counter.to_i + 1
  mid_number = $counter.to_s.rjust(8,'0')
  ben = "#{district_code}/#{mid_number}/2017"
  ActiveRecord::Base.connection.execute <<EOF
    UPDATE person_birth_details SET district_id_number = '#{ben}' WHERE person_id = #{person_id}
EOF

  PersonIdentifier.new_identifier(person_id, 'Birth Entry Number', ben)

  ben
end

def mass_data
=begin
    data = [{
        "Surname"=> "Ferrirad",
        "OtherNames"=> "Moses",
        "FirstName"=> "Masula",
        "DateOfBirthString"=>"02/12/2017",
        "Sex"=> 1,
        "Nationality"=> "MWI",
        "Nationality2"=> "",
        "Status"=>"Normal",
        "TypeOfBirth" => "Single",
        "ModeOfDelivery" => "Breech",
        "LevelOfEducation" => "none",
        "MotherPin"=> '4BSBY839',
        "MotherSurname"=> "Banda",
        "MotherMaidenName"=> "Mwandala",
        "MotherFirstName"=> "Zeliya",
        "MotherOtherNames"=>"Julia",
        "MotherNationality"=>"MWI",
        "FatherPin"=> "4BSBY810",
        "FatherSurname"=> "Kapundi",
        "FatherFirstName"=> "Kangaonde",
        "FatherOtherNames"=> "Masula",
        "FatherVillageId"=>-1,
        "FatherNationality"=>"MWI",
        "EbrsPk"=> nil,
        "NrisPk"=>nil,
        "PlaceOfBirthDistrictId"=>-1,
        "PlaceOfBirthDistrictName" => "Lilongwe",
        "PlaceOfBirthTAName" => "Chadza",
        "PlaceOfBirthVillageName" => "Maluwa",
        "PlaceOfBirthVillageId"=>-1,
        "MotherDistrictId"=>-1,
        "MotherDistrictName"=> "Lilongwe",
        "MotherTAName"=> "Chadza",
        "MotherVillageName"=> "Kaphantengo",
        "MotherVillageId"=>-1,
        "FatherDistrictId"=> -1,
        "FatherDistrictName"=> "Lilongwe",
        "FatherTAName" => "Chadza",
        "FatherVillageName" => "Masula",
        "EditUser"=> "Dataman1",
        "EditMachine"=>"192.168.43.5",
        "BirthCertificateNumber"=> "00000200001",
        "DistrictOfRegistration" => "Lilongwe",
        "MotherAge" => "30",
        "FatherAge" => "30",
        "DateRegistered" => "02/11/2017"
        "Category" => ""
    }]
=end

  district = Location.find(SETTINGS['location_id'])
  district_name = district.name
  district_code = district.code
  puts "DISTRICT: #{district_name}, CODE: #{district_code}"
  last_2017_ben = ActiveRecord::Base.connection.execute <<EOF
    SELECT MAX(district_id_number) ben FROM person_birth_details WHERE district_id_number LIKE '#{district_code}/%2017';
EOF
  last_2017_ben =  last_2017_ben.first[0]
  $counter = last_2017_ben.split("/")[1].to_i


  columns = ActiveRecord::Base.connection.execute <<EOF
    SHOW columns FROM mass_data;
EOF

  columns = columns.collect{|c| c[0]}
  data = ActiveRecord::Base.connection.execute <<EOF
    SELECT * FROM mass_data WHERE DistrictOfRegistration = '#{district_name}'
      AND category NOT IN ('BiologicalMother-Separated', 'BiologicalMother-Abandoned')
EOF

  ActiveRecord::Base.connection.execute <<EOF
    UPDATE mass_data SET load_status = NULL WHERE DistrictOfRegistration = '#{district_name}'
      AND category NOT IN ('BiologicalMother-Separated', 'BiologicalMother-Abandoned')
EOF

  data.each do |nid_child|

    hash = {}
    nid_child.each_with_index do |value, i|
      value = (value.to_s.split.map(&:capitalize).join(' ') rescue value) unless ["FathePin", "MotherPin", "DateOfBirthString"].include?(columns[i])
      hash[columns[i]] = value
    end


    ActiveRecord::Base.transaction do
      hash = hash.with_indifferent_access

      person = {}
      person["id"] = ""
      person["first_name"]= hash["FirstName"] rescue ''
      person["last_name"] =  hash["Surname"] rescue ''
      person["middle_name"] = hash["OtherNames"] rescue ''
      person["gender"] = hash["Sex"]
      person["birthdate"]= ((hash["DateOfBirthString"].to_date) rescue (raise hash["DateOfBirthString"]))
      person["birthdate_estimated"] = 0
      person["nationality"]=  $codes[hash["Nationality"]]
      person["place_of_birth"] = "Other"
      person["district"] = hash["PlaceOfBirthDistrictName"]

      person["mother_first_name"]= hash["MotherFirstName"]
      person["mother_last_name"] =  hash["MotherSurname"]
      person["mother_middle_name"] = hash["MotherOtherNames"]

      person["mother_home_district"] = hash["MotherDistrictName"]
      person["mother_home_ta"] = hash["MotherTaName"]
      person["mother_home_village"] = hash["MotherVillageName"]

      person["mother_current_district"] = nil
      person["mother_current_ta"] = nil
      person["mother_current_village"] = nil

      person["father_first_name"]= hash["FatherFirstName"]
      person["father_last_name"] =  hash["FatherSurname"]
      person["father_middle_name"] = hash["FatherOtherNames"]

      person["father_home_district"] = hash["FatherDistrictName"]
      person["father_home_ta"] = hash["FatherTaName"]
      person["father_home_village"] = hash["FatherVillageName"]

      person["father_current_district"] = nil
      person["father_current_ta"] = nil
      person["father_current_village"] = nil

      duplicates = SimpleElasticSearch.query_duplicate_coded(person,SETTINGS['duplicate_precision'])

      if duplicates.present?
        puts "Duplicate found!"
        ActiveRecord::Base.connection.execute <<EOF
    UPDATE mass_data SET load_status = 'Duplicate' WHERE DistrictOfRegistration = '#{district_name}' AND id = #{nid_child[0]}
EOF
      else
        SimpleElasticSearch.add(person)

        person_id = PersonService.create_nris_person(hash)
        ben = assign_next_ben(person_id, district_code)
        puts "#{person_id} # #{ben}"

        ActiveRecord::Base.connection.execute <<EOF
    UPDATE mass_data SET load_status = 'Success' WHERE DistrictOfRegistration = '#{district_name}' AND id = #{nid_child[0]}
EOF
      end
    end
  end
end

puts "Mass Data Import Starting"
mass_data
