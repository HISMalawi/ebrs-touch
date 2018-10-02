
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

  MassPerson.where(upload_status: "NOT UPLOADED").each do |record|
    ActiveRecord::Base.transaction do
      record.map_to_ebrs_tables(upload_number)
    end
  end

  puts "#{MassPerson.where(" upload_status  = 'NOT UPLOADED' ").count} Records to be Loaded"
  puts "#{MassPerson.where(" upload_status  = 'UPLOADED' ").count} Records Already Loaded"
  puts "Done"
else
  puts "Stopped"
end
