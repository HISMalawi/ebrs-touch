def self.generate_stats(types=['Normal', 'Adopted', 'Orphaned', 'Abandoned'], approved=true)
    result = {}
    birth_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

    faulty_ids = [-1] + PersonRecordStatus.find_by_sql("SELECT prs.person_record_status_id FROM person_record_statuses prs
                                                LEFT JOIN person_record_statuses prs2 ON prs.person_id = prs2.person_id AND prs.voided = 0 AND prs2.voided = 0
                                                WHERE prs.created_at < prs2.created_at;").map(&:person_record_status_id)

    Status.all.each do |status|
      result[status.name] = PersonRecordStatus.find_by_sql("
      SELECT COUNT(*) c FROM person_record_statuses s
        INNER JOIN person_birth_details p ON p.person_id = s.person_id
          AND p.birth_registration_type_id IN (#{birth_type_ids.join(', ')})
        WHERE voided = 0 AND s.person_record_status_id NOT IN (#{faulty_ids.join(', ')}) AND status_id = #{status.id}")[0]['c']
    end

    unless approved == false
    excluded_states = ['HQ-REJECTED', 'HQ-VOIDED', 'HQ-PRINTED', 'HQ-DISPATCHED'].collect{|s| Status.find_by_name(s).id}
    included_states = Status.where("name like 'HQ-%' ").map(&:status_id)

    result['APPROVED BY ADR'] =  PersonRecordStatus.find_by_sql("
      SELECT COUNT(*) c FROM person_record_statuses s
        WHERE voided = 0 AND status_id IN = 8 ")[0]['c']
    end
    result    
    File.open("#{Rails.root}/db/stats.json","w") do |f|
      f.write(result.to_json)
    end 
end

generate_stats()
