person_ids = PersonBirthDetail.all.map(&:person_id)
person_ids.each_with_index do |person_id, i|
	active_statuses = PersonRecordStatus.where(person_id: person_id, voided: 0).count
    active_statuses = active_statuses.to_i

    i = 1

    if active_statuses > 1
    	 for i in 1..active_statuses-1 do
    	 	prs = PersonRecordStatus.where(person_id: person_id, voided: 0).order('created_at asc').first
            prs.voided = 1
            prs.save
            prs.save
            prs.save
            prs.save
        end
    end

	puts "#{(i + 1)} # person_id: #{person_id}"
end
