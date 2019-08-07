bens = File.read("parent_married_but_no_father").split("\n")
user_id = User.where(username: "admin279").first.id

bens.each_with_index do |ben, i|
	person_id = PersonBirthDetail.where(district_id_number: ben).first.person_id
	puts "#{i} # #{ben} # #{person_id}"
	PersonRecordStatus.new_record_state(person_id, "DC-INCOMPLETE", "MISSING FATHER DETAILS", user_id)
end
