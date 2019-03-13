
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


last_2018_ben = ActiveRecord::Base.connection.execute <<EOF
    SELECT MAX(district_id_number) ben FROM person_birth_details;
EOF


last_2018_ben2 = ActiveRecord::Base.connection.execute <<EOF
    SELECT MAX(value) ben FROM person_identifiers WHERE value LIKE '%/%/%2018';
EOF

last_2018_ben =  [(last_2018_ben.first[0].split("/")[1].to_i rescue 0), (last_2018_ben2.first[0].split("/")[1].to_i rescue 0)].max

$counter = last_2018_ben
$district_code = Location.find(SETTINGS['location_id']).code
puts $counter
puts "Last BEN: #{$counter}"

if MassPerson.where(" upload_status  = 'NOT UPLOADED' ").count > 0
  puts "Upload Number: #{upload_number}"
  puts "#{MassPerson.where(" upload_status  = 'NOT UPLOADED' ").count} Records to be Loaded"
  puts "#{MassPerson.where(" upload_status  = 'UPLOADED' ").count} Records Already Loaded"

  puts "Proceed to load data Y/N"
  response = gets
else
  puts "No Records Found to Load"
end

def assign_next_ben(person_id)

  $counter = $counter.to_i + 1
  mid_number = $counter.to_s.rjust(8,'0')
  ben = "#{$district_code}/#{mid_number}/2018"
  ActiveRecord::Base.connection.execute <<EOF
    UPDATE person_birth_details SET district_id_number = '#{ben}' WHERE person_id = #{person_id}
EOF

  PersonIdentifier.new_identifier(person_id, 'Birth Entry Number', ben)

  ben
end

if ["YES", "Y"].include?(response.chomp.to_s.upcase)

  incomplete = [MassPerson.new.attributes.keys.join(",")]
  exact_dup  = [MassPerson.new.attributes.keys.join(",")]
  potential_dup = [MassPerson.new.attributes.keys.join(",")]
  MassPerson.where(upload_status: "NOT UPLOADED").each do |record|

    status = "HQ-CAN-PRINT"
    outcome = "Success"

    #Filter for Complete Cases
    if ([record["last_name"], record["first_name"], record["gender"], record["date_of_birth"],
         record["mother_last_name"], record["mother_first_name"], record["mother_nationality"],
         record["district_of_birth"], record["ta_of_birth"], record["village_of_birth"] ] & ["", nil]).length > 0 ||
        ((!record["father_first_name"].blank? || !record["father_last_name"].blank? ||
            !record["father_nationality"].blank? ) &&
        ([record["father_first_name"], record["father_last_name"],
         record["father_nationality"]] & ["", nil]).length > 0)

      status = "DC-INCOMPLETE"
      outcome = "Incomplete Record"
      incomplete << record.attributes.values.join(",")
    end

    formated = MassPerson.format_person(record)
    exact_duplicates =  MassPerson.exact_duplicates(record) #SimpleElasticSearch.query_duplicate_coded(formated, 100)


    if exact_duplicates.length > 0

      status = "DC-DUPLICATE"
      outcome = "Exact Duplicate"
      exact_dup << record.attributes.values.join(",")
    end

    potential_duplicates = SimpleElasticSearch.query_duplicate_coded(formated, 85)
    if potential_duplicates.length > 0
      status = "DC-POTENTIAL DUPLICATE"
      outcome = "Potential Duplicate"
      potential_dup << record.attributes.values.join(",")
    end

    ActiveRecord::Base.transaction do
      person_id = record.map_to_ebrs_tables(upload_number, status)

      if exact_duplicates.present?
        exact_duplicate = PotentialDuplicate.create(person_id: person_id, created_at: (Time.now))
        exact_duplicates.each do |pid|
          exact_duplicate.create_duplicate(pid) #rescue nil
        end
      end

      if potential_duplicates.present?
        potential_duplicate = PotentialDuplicate.create(person_id: person_id, created_at: (Time.now))
        potential_duplicates.each do |result|
          potential_duplicate.create_duplicate(result["_id"]) #rescue nil
        end
      end

      if status == "HQ-CAN-PRINT"
        assign_next_ben(person_id)
      end

      RecordChecks.create(
          person_id: person_id,
          outcome: outcome
      )

      formated["id"] = person_id
      SimpleElasticSearch.add(formated)

      puts "#{person_id} # #{status} # #{outcome}"
    end
  end

  puts "Done"
else
  puts "Stopped"
end
