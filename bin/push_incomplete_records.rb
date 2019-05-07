bn = ActiveRecord::Base.connection.execute <<EOF
    SELECT MAX(district_id_number) ben FROM person_birth_details WHERE district_id_number LIKE '%/%/%2018';
EOF

$district_code = Location.find(SETTINGS['location_id']).code
User.current = User.where(username: "admin279").first

bn = bn.first.first
bn = bn.split("/").second.to_i

records = RecordChecks.where(" outcome = 'Incomplete Record' ")
records.each do |record|

  person_id = record.person_id
  pbd = PersonBirthDetail.where(person_id: person_id).first

  if pbd.district_id_number.blank?

    bn = bn + 1
    mid_number = bn.to_s.rjust(8,'0')

    ben = "#{$district_code}/#{mid_number}/2018"
    pbd.district_id_number = ben
    pbd.save

    PersonIdentifier.new_identifier(person_id, 'Birth Entry Number', ben)
  end

  PersonRecordStatus.new_record_state(person_id, "HQ-ACTIVE", "Community Data Status Change for Incomplete Record")

  record.outcome = "Success"
  record.save

  puts "#{person_id} # #{pbd.district_id_number}"
end