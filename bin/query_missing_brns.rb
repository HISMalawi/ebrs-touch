records = File.read("ben_numbers_skipped.csv").split("\n")
user_id = User.where(username: "admin279").first.id

records.each do |line|

puts line.strip
d = PersonBirthDetail.where(district_id_number: line).last
puts d.person_id
PersonRecordStatus.new_record_state(d.person_id, "HQ-CAN-PRINT", "Reprint Due to Misplaced Blank Numbers", user_id)

end
