
suspected = []
champiti  = Location.where(name: "Champiti").first
villages  = {}
Location.where(parent_location: champiti.id).each do |loc|
	villages[loc.name] = loc.id
end
puts villages
k = 0
File.read("success_records").split("\n").each_with_index do |mass_person_id, i|
		
		mass_person = MassPerson.find(mass_person_id)		
		detail = PersonBirthDetail.where(" source_id LIKE '-#{mass_person_id}#%' ").last
		status = PersonRecordStatus.where(voided: 0, person_id: detail.person_id).last.status.name
		#location_id = villages[mass_person.location_created_at]	

		#if detail.location_created_at.to_i != location_id.to_i
		#	k += 1
		#	puts " #{i} ## #{detail.location_created_at} ## #{location_id} ## #{k}"
		#	detail.location_created_at = location_id
		#	detail.save
		#end

		#next

		if status != 'DC-PRINTED' && status != "DC-INCOMPLETE"
		puts status	
		suspected << detail.person_id
			puts "#{i} ## #{mass_person_id} # #{detail.person_id} # SUSPECTED: #{suspected.count} "
		end
end
