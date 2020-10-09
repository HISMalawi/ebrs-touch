status_id = Status.where(name: "HQ-CAN-PRINT").first.id

person_ids = PersonRecordStatus.find_by_sql("
	 SELECT d.person_id FROM person_birth_details d
        INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
        WHERE d.person_id LIKE '100250%'
         AND d.source_id LIKE '-%#%' AND d.created_at > '2020-01-01'  AND prs.status_id = #{status_id} AND prs.voided = 0
	 ").map(&:person_id).uniq

puts person_ids.count

person_ids.each_with_index do |person_id, i|
	detail = PersonBirthDetail.where(person_id: person_id).first

	child_id = detail.person_id

	mother = PersonRelationship.where(person_a: person_id, person_relationship_type_id: 5).first
	mother_id = mother.person_b rescue nil

	address = PersonAddress.where(person_id: mother_id).first
	nationality = address.citizenship rescue nil

	if nationality.blank? || nationality == 35763
                mother_address = PersonAddress.where(person_id: mother_id).first
                next if mother_address.blank?
                #raise child_id.inspect
		mother_address.citizenship = 154
		mother_address.save

		puts "#{child_id} ## #{address.citizenship}"
	end
  
end
