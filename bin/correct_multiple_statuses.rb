cur_loc_id = SETTINGS['location_id']
cur_loc_name = Location.find(cur_loc_id).name
district_code = Location.find(cur_loc_id).code

person_ids = PersonRecordStatus.find_by_sql("
	 SELECT distinct d.person_id FROM person_birth_details d
	INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
	 ").map(&:person_id).uniq
person_ids.each_with_index do |person_id, i|
	active_statuses = PersonRecordStatus.where(person_id: person_id, voided: 0).count
    active_statuses = active_statuses.to_i

    i = 1

    if active_statuses > 1
    	 for i in 1..active_statuses-1 do
    	 	prs = PersonRecordStatus.where(person_id: person_id, voided: 0).order('created_at asc').first
            prs.voided = 1
            prs.save

        end
        puts "Corrected # person_id: #{person_id}"
    else
        puts "No active more than one active statuses for # person_id #{person_id}"
    end

end
