status_id = Status.where(name: "HQ-CAN-PRINT").first.id

person_ids = PersonRecordStatus.find_by_sql("
	 SELECT d.person_id FROM person_birth_details d
        INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
        WHERE d.person_id LIKE '100250%'
         AND d.source_id LIKE '-%#%' AND d.created_at > '2020-01-01'  AND prs.status_id = #{status_id} AND prs.voided = 0
	 ").map(&:person_id).uniq

puts person_ids.count

user = User.where(username: "admin279").first

person_ids.each_with_index do |person_id, i|
	detail = PersonBirthDetail.where(person_id: person_id).first

	child_id = detail.person_id

	mother = PersonRelationship.where(person_a: person_id, person_relationship_type_id: 5).first
	mother_id = mother.person_b rescue nil

	address = PersonAddress.where(person_id: mother_id).first
	nationality = address.citizenship rescue nil

	if nationality.blank? || nationality == 35763
	    a = PersonService.force_sync_remote(person_id)
            b = PersonService.force_sync_remote(mother_id)
            puts "#{person_id} ## #{a}"
	end
  
end
