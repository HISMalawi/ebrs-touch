status_id = Status.where(name: "HQ-CAN-PRINT").first.id

#ids = PersonIdentifier.where(person_identifier_type_id: 4, voided: 0).pluck("person_id");
person_ids = PersonRecordStatus.find_by_sql("
	 SELECT prs.person_id FROM person_record_statuses prs
	INNER JOIN person_birth_details d ON d.person_id = prs.person_id AND d.source_id LIKE '%#%'
	INNER JOIN person p ON p.person_id = prs.person_id 
	WHERE prs.status_id = #{status_id} AND prs.voided = 0
	AND TIMESTAMPDIFF(YEAR, p.birthdate, CURDATE()) < 16
	AND p.person_id NOT IN (
	  SELECT pid.person_id FROM person_identifiers pid WHERE pid.person_identifier_type_id = 4 AND pid.voided = 0
	)").map(&:person_id)

puts person_ids.count
person_ids.each_with_index do |person_id|
  puts  "#{person_id} # #{person_ids.count}"
  PersonService.request_nris_id_remote(person_id)
end
