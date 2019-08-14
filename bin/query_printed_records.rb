status_id = Status.where(name: "DC-PRINTED").last.id
champiti  = Location.where(name: "Champiti").first
loc_ids = Location.where(parent_location: champiti.id).map(&:location_id)
data = {}

loc_ids.each do |l|
	name = Location.find(l).name
	person_ids = PersonBirthDetail.where(location_created_at: l).pluck :person_id
	person_ids << -1
	print_statuses = PersonRecordStatus.where(" person_id IN (#{person_ids.join(',')}) AND status_id = #{status_id} ").select("person_id").uniq

	puts "#{l} #{name}"
	data[name] = print_statuses.count
end

=begin
PersonBirthDetail.find_by_sql("SELECT d.location_created_at, COUNT(DISTINCT(d.person_id)) total FROM person_birth_details d 
		 INNER JOIN person_record_statuses s ON d.person_id = s.person_id AND s.voided = 0
		 WHERE s.status_id = #{status_id} AND (d.source_id IS NOT NULL AND d.source_id LIKE '%#%' ) 
			AND d.location_created_at IN (#{loc_ids.join(',')}) 
		 GROUP BY d.location_created_at ").each{|d|
		l = Location.find(d.location_created_at)
		data[l.name] = d.total
}
=end

puts data.keys.length
puts data.values.sum
puts data
