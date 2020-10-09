status_id = Status.where(name: "HQ-CAN-PRINT").first.id
person_ids = PersonRecordStatus.find_by_sql("
         SELECT d.person_id FROM person_birth_details d
        INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
        WHERE d.person_id LIKE '100250%' AND d.national_serial_number IS NULL
         AND d.source_id LIKE '-%#%' AND d.created_at > '2020-01-01'  AND prs.status_id = #{status_id} AND prs.voided = 0
         ").map(&:person_id).uniq

puts person_ids.count
#raise '######'.to_s
user = User.where(username: "admin279").first

person_ids.each_with_index do |person_id, i|

   a = PersonService.force_sync_remote(person_id) rescue nil
 
   puts "#{i} ## #{person_id} ## #{a}"

end

