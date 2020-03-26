
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

$district_code = Location.find(SETTINGS['location_id']).code

last_2018_ben = ActiveRecord::Base.connection.execute <<EOF
    SELECT MAX(district_id_number) ben FROM person_birth_details WHERE district_id_number LIKE '%/%/%2018';
EOF

last_2018_ben2 = ActiveRecord::Base.connection.execute <<EOF
    SELECT MAX(value) ben FROM person_identifiers WHERE value LIKE '%/%/%2018';
EOF

last_2018_ben =  [(last_2018_ben.first[0].split("/")[1].to_i rescue 0), (last_2018_ben2.first[0].split("/")[1].to_i rescue 0)].max

$counter = last_2018_ben

def assign_next_ben(person_id)

  $counter = $counter.to_i + 1
  mid_number = $counter.to_s.rjust(8,'0')
  ben = "#{$district_code}/#{mid_number}/2018"
	detail = PersonBirthDetail.where(person_id: person_id).first
	detail.district_id_number = ben
  #PersonIdentifier.new_identifier(person_id, 'Birth Entry Number', ben)
	if detail.save
	  ben
	end 
end

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

	upload_number = 2
	status				= "DC-ACTIVE"

  MassPerson.where(upload_status: "NOT UPLOADED").each_with_index do |record, i|

      person_id = record.map_to_ebrs_tables(upload_number, status)		
			puts "#{person_id} # COUNT: #{(i + 1)}"
  end

  puts "Done"
else
  puts "Stopped"
end
