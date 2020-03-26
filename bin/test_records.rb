names = [
			['Madalitso', 'Kumwenda'],
			['Thabit', 'Issa'],
			['Madalitso', 'Kamwendo'],
			['Hope', 'Kaphukusi'],
			['Thabit', 'Issah'],
			['Kenneth', 'Kapundi'],
			['Aggie', 'Phiri'],
			['Madalitso', 'Kamwando'],
			['Adwell', 'Gidara'],
			['Ferriard', 'Lupiya'],
			['Kenneth', 'Kapundi']
	]

names.each do |first_name, last_name|
	puts "#{first_name}, #{last_name}"

	data = PersonBirthDetail.find_by_sql(" SELECT * FROM person_birth_details d INNER JOIN person_name n ON d.person_id = n.person_id WHERE n.first_name = '#{first_name}' AND 	n.last_name = '#{last_name}' AND d.source_id LIKE '%#%' ")
	
	data.each do |record|
		PersonRecordStatus.new_record_state(record.person_id, 'DC-VOIDED', 'BRK Test Record Voided',  User.where(username: 'admin279').first.id)
	end 
end
