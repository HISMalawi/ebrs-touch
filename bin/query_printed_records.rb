status_id = Status.where(name: "DC-PRINTED").last.id
p = PersonBirthDetail.find_by_sql("SELECT * FROM person_birth_details d 
		 INNER JOIN person_record_statuses s ON d.person_id = s.person_id AND s.voided = 0
		 WHERE s.status_id = #{status_id} AND (d.source_id IS NOT NULL AND d.source_id LIKE '%#%' ) ")

puts "#{p.length} Records"
