person_ids = PersonRecordStatus.find_by_sql("
	 SELECT distinct d.person_id FROM person_birth_details d
	INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
	WHERE prs.status_id = 62 AND prs.voided = 0 AND d.district_id_number like '#{district_code}/%'
	 ").map(&:person_id).uniq

person_ids.each_with_index do |person_id, i|
	prs = PersonRecordStatus.where(person_id: person_id, status_id: 62, voided: 0).last
	i = 1
	for i in 1..20 do
		prs.save
	end

	puts "#{i}:  #{person_id} done"
end