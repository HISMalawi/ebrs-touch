status_id = Status.where(name: "HQ-CAN-PRINT").first.id

person_ids = PersonRecordStatus.find_by_sql("
	 SELECT d.person_id FROM person_birth_details d
        INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
        WHERE d.person_id LIKE '100250%'
         AND d.source_id LIKE '-%#%'  AND prs.status_id = 62 AND prs.voided = 0
	 ").map(&:person_id).uniq

puts person_ids.count
#raise '######'.to_s
user = User.where(username: "admin279").first.id

#raise user.inspect

person_ids.each_with_index do |person_id, i|

	informant = PersonRelationship.where(person_a: person_id, person_relationship_type_id: 4).first
	informant_id = informant.person_b

	informant_address = PersonAddress.where(person_id: informant_id).first
	informant_ta = informant_address.current_ta rescue nil
	informant_village = informant_address.current_village rescue nil

	if informant_ta == 34130 && informant_village == 34236 
		old_status = PersonRecordStatus.where(person_id: person_id, status_id: 62, voided: 0).first
		old_status.voided = 1
		old_status.voided_by = user
		old_status.comments = "Printed faint due to tonner"
		old_status.save

		new_status = PersonRecordStatus.new(status_id: 44, person_id: person_id, creator: user, voided: 0, void_reason: nil, voided_by: nil, date_voided: nil, comments: 'Pushed back to print queue after being printed faint')
		new_status.save
		puts "#{i} #{person_id} ## #{informant_ta} ## #{informant_village} Mbiya"
	end

	if informant_ta == 34130 && informant_village == 34234
		old_status = PersonRecordStatus.where(person_id: person_id, status_id: 62, voided: 0).first
		old_status.voided = 1
		old_status.voided_by = user
		old_status.comments = "Printed faint due to tonner"
		old_status.save

		new_status = PersonRecordStatus.new(status_id: 44, person_id: person_id, creator: user, voided: 0, void_reason: nil, voided_by: nil, date_voided: nil, comments: 'Pushed back to print queue after being printed faint')
		new_status.save
		puts "#{i} #{person_id} ## #{informant_ta} ## #{informant_village} Matipani"
	end

end #end loop