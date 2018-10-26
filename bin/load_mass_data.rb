
upload_number   = MassPerson.find_by_sql(" SELECT MAX(upload_number) n FROM mass_person ").last['n'].to_i + 1


User.current = User.where(username: "admin#{SETTINGS['location_id']}").last
response = "N"

ActiveRecord::Base.connection.execute <<EOF
ALTER TABLE person_birth_details MODIFY number_of_children_born_alive_inclusive INT NULL
EOF

ActiveRecord::Base.connection.execute <<EOF
ALTER TABLE person_birth_details MODIFY number_of_children_born_still_alive INT NULL
EOF

ActiveRecord::Base.connection.execute <<EOF
ALTER TABLE person_birth_details MODIFY number_of_prenatal_visits INT NULL
EOF

if MassPerson.where(" upload_status  = 'NOT UPLOADED' ").count > 0
  puts "Upload Number: #{upload_number}"
  puts "#{MassPerson.where(" upload_status  = 'NOT UPLOADED' ").count} Records to be Loaded"
  puts "#{MassPerson.where(" upload_status  = 'UPLOADED' ").count} Records Already Loaded"

  puts "Proceed to load data Y/N"
  response = gets
else
  puts "No Records Found to Load"
end

if ["YES", "Y"].include?(response.chomp.to_s.upcase)

  incomplete = [MassPerson.new.attributes.keys.join(",")]
  exact_dup  = [MassPerson.new.attributes.keys.join(",")]
  potential_dup = [MassPerson.new.attributes.keys.join(",")]
  MassPerson.where(upload_status: "NOT UPLOADED").each do |record|

    status = "HQ-CAN-PRINT"

    #Filter for Complete Cases
    if ([record["last_name"], record["first_name"], record["gender"], record["date_of_birth"],
         record["mother_last_name"], record["mother_first_name"], record["mother_nationality"],
         record["district_of_birth"], record["ta_of_birth"], record["village_of_birth"] ] & ["", nil]).length > 0 ||
        ((!record["father_first_name"].blank? || !record["father_last_name"].blank? ||
            !record["father_nationality"].blank? ) &&
        [record["father_first_name"], record["father_last_name"],
         record["father_nationality"]] & ["", nil]).length > 0

      status = "DC-INCOMPLETE"
      incomplete << record.attributes.values.join(",")
    end

    formated = MassPerson.format_person(record)
    if SimpleElasticSearch.query_duplicate_coded(formated, 100).length > 0

      exact_dup << record.attributes.values.join(",")
      record.upload_datetime = Time.now
      record.upload_number = upload_number
      record.upload_status = "UPLOADED"
      record.save!

      next
    end

    potential_duplicates = SimpleElasticSearch.query_duplicate_coded(formated, 80)
    if potential_duplicates.length > 0
      status = "DC-POTENTIAL DUPLICATE"
      potential_dup << record.attributes.values.join(",")
    end

    ActiveRecord::Base.transaction do
      person_id = record.map_to_ebrs_tables(upload_number, status)

      potential_duplicates.each do |dup|
        potential_duplicate = PotentialDuplicate.create(person_id: person_id, created_at: (Time.now))
        if potential_duplicates.present?
          potential_duplicates.each do |result|
            puts result["_id"]
            potential_duplicate.create_duplicate(result["_id"]) #rescue nil
          end
        end
      end

      formated["id"] = person_id
      SimpleElasticSearch.add(formated)
    end
  end

  File.open("IncompleteRecords.csv", "w"){|f| f.write(incomplete.join("\n"))}
  File.open("ExactDuplicates.csv", "w"){|f| f.write(exact_dup.join("\n"))}
  File.open("PotentialDuplicates.csv", "w"){|f| f.write(potential_dup.join("\n"))}

  puts "Done"
else
  puts "Stopped"
end
