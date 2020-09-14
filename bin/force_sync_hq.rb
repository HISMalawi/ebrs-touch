status_id = Status.where(name: "HQ-ACTIVE").first.id
person_ids = PersonRecordStatus.find_by_sql("
         SELECT d.person_id FROM person_birth_details d
        INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
        WHERE prs.status_id = #{status_id} AND prs.voided = 0 AND d.district_id_number like 'NU/%'
         ").map(&:person_id).uniq

puts person_ids.count
#raise '######'.to_s
#user = User.where(username: "admin279").first

person_ids.each_with_index do |person_id, i|

        a = PersonService.force_sync_remote(person_id) rescue nil

  #d = PersonBirthDetail.where(person_id: person_id).first
  #brn = d.generate_brn
        puts "#{i} ## #{person_id} ## #{a}"
end

