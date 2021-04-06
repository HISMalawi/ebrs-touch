status_id = Status.where(name: "HQ-ACTIVE").first.id

location = Location.find(SETTINGS['location_id'])
district_code = location.code

person_ids = PersonRecordStatus.find_by_sql("
	 SELECT distinct d.person_id FROM person_birth_details d
	INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
	WHERE prs.status_id = #{status_id}
	 ").map(&:person_id).uniq

puts person_ids.count
#raise '######'.to_s
user = User.where(username: "admin279").first.id

person_ids.each_with_index do |person_id, i|
	hq_active = PersonRecordStatus.where(person_id: person_id, status_id: 8).last
	if !hq_active.blank?
		dc_complete = PersonRecordStatus.where(person_id: person_id, status_id: 5).order('created_at asc').last

		if !dc_complete.blank?
			if dc_complete.voided != 1
				dc_complete.voided = 1
				dc_complete.voided_by = hq_active.creator
				dc_complete.save

				puts "Removed #{person_id} from DC-COMPELE list"
			end
		end
	end
end
