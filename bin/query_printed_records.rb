status_id = Status.where(name: "DC-PRINTED").last.id
champiti  = Location.where(name: "Champiti").first
loc_ids = Location.where(parent_location: champiti.id).map(&:location_id)
data = {}

PersonBirthDetail.find_by_sql("SELECT d.location_created_at, COUNT(*) total FROM person_birth_details d 
		 INNER JOIN person_record_statuses s ON d.person_id = s.person_id AND s.voided = 0
		 WHERE s.status_id = #{status_id} AND (d.source_id IS NOT NULL AND d.source_id LIKE '%#%' ) 
			AND d.location_created_at IN (#{loc_ids.join(',')}) 
		 GROUP BY d.location_created_at ").each{|d|
		l = Location.find(d.location_created_at)
		data[l.name] = d.total
}

puts data.values.sum
puts data
