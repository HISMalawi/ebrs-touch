
cur_loc_id = SETTINGS['location_id']
cur_loc_name = Location.find(cur_loc_id).name
district_code = Location.find(cur_loc_id).code


status_id = Status.where(name: "HQ-ACTIVE").first.id
person_ids = PersonRecordStatus.find_by_sql("
         SELECT d.person_id FROM person_birth_details d
        INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
        WHERE prs.status_id = #{status_id} AND prs.voided = 0 AND d.district_id_number like '#{district_code}/%'
         ").map(&:person_id).uniq

puts person_ids.count

person_ids.each_with_index do |person_id, i|

        a = PersonService.force_sync_remote(person_id) rescue nil
        
        #next if active_statuses > 1

        puts "#{i} ## #{person_id} ## #{a}"
end