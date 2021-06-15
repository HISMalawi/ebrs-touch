year = ""
person_ids = PersonRecordStatus.find_by_sql("
	 SELECT distinct d.person_id FROM person_birth_details d
	INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
	WHERE prs.status_id = 8 AND d.district_id_number IS NULL AND prs.created_at > '2019-12-31' and prs.created_at < '2021-01-01'
	 ").map(&:person_id).uniq

person_ids.each_with_index do |person_id, i|
	a = PersonBirthDetail.where(person_id: person_id).first
	a.fix_missing_bens(year)

	puts "#{person_id} #  #{a.district_id_number}"
end