class Report < ActiveRecord::Base
  def self.births_report(start_date, end_date, status="Reported")

    start_date = start_date.to_date.to_s
    end_date = end_date.to_date.to_s
    if status == "Reported"
      status_ids = Status.all.map{|m| m.status_id}.join(",")
    else
      status_ids = Status.where(name: status).map{|m| m.status_id}.join(",")
    end

    total_male   =  0
    total_female =  0

    reg_type = {}
    ['Normal', 'Abandoned', 'Adopted', 'Orphaned'].each do |type|
      reg_type[type] = {}
      
      male =  ActiveRecord::Base.connection.select_all(

            "SELECT COUNT(*) AS total FROM person_birth_details pbd
                  INNER JOIN person p ON p.person_id = pbd.person_id
                  INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  INNER JOIN birth_registration_type t ON t.birth_registration_type_id = pbd.birth_registration_type_id AND t.name = '#{type}'
                WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                AND prs.status_id IN (#{status_ids})
                GROUP BY p.gender, pbd.birth_registration_type_id
              "
      ).as_json.last['total'] rescue 0
      reg_type[type]['Male']  = male

      female =  ActiveRecord::Base.connection.select_all(

          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                  INNER JOIN person p ON p.person_id = pbd.person_id
                  INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  INNER JOIN birth_registration_type t ON t.birth_registration_type_id = pbd.birth_registration_type_id AND t.name = '#{type}'
                  WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                  AND prs.status_id IN (#{status_ids})
                  GROUP BY p.gender, pbd.birth_registration_type_id
              "
      ).as_json.last['total'] rescue 0
      reg_type[type]['Female'] = female

      total_male = total_male + male
      total_female = total_female + female
      
    end

    parents_married  = {}
    [0, 1].each do |k|
      parents_married[(k == 0 ? 'No' : 'Yes')] = {}
      parents_married[(k == 0 ? 'No' : 'Yes')]['Male'] =  ActiveRecord::Base.connection.select_all(

          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}'
                    AND pbd.parents_married_to_each_other = #{k} AND p.gender = 'M'
                    AND prs.status_id IN (#{status_ids})
                    GROUP BY p.gender, pbd.parents_married_to_each_other
                "
      ).as_json.last['total'] rescue 0
      parents_married[(k == 0 ? 'No' : 'Yes')]['Female'] =  ActiveRecord::Base.connection.select_all(

          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}'
                    AND pbd.parents_married_to_each_other = #{k} AND p.gender = 'F'
                    AND prs.status_id IN (#{status_ids})
                "
      ).as_json.last['total'] rescue 0
    end

    delayed = {}
    ['No', 'Yes'].each do |k|
      delayed[k] = {}
      c = (k == 'Yes') ? '>' : '<='

      delayed[k]['Male'] =  ActiveRecord::Base.connection.select_all(
          "SELECT COUNT(*) AS total FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                  AND DATEDIFF(pbd.date_registered, p.birthdate) #{c} 42
                  AND prs.status_id IN (#{status_ids})
                "
      ).as_json.last['total'] rescue 0

      delayed[k]['Female'] =  ActiveRecord::Base.connection.select_all(
          "SELECT COUNT(*) AS total, p.gender FROM person_birth_details pbd
                    INNER JOIN person p ON p.person_id = pbd.person_id
                    INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                  WHERE DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                  AND DATEDIFF(pbd.date_registered, p.birthdate) #{c} 42
                  AND prs.status_id IN (#{status_ids})
                "
      ).as_json.last['total'] rescue 0
    end

    place_of_birth = {}

    ['Home','Hospital','Other'].each do |k|
        place_of_birth[k] = {}
        
        male =  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                      INNER JOIN person p ON p.person_id = pbd.person_id
                      INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.place_of_birth = (SELECT location_id FROM location WHERE name = '#{k}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'M'
                    AND prs.status_id IN (#{status_ids})
                    GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0
        place_of_birth[k]['Male']  = male

        female=  ActiveRecord::Base.connection.select_all(

                "SELECT COUNT(*) AS total FROM person_birth_details pbd
                      INNER JOIN person p ON p.person_id = pbd.person_id
                      INNER JOIN person_record_statuses prs ON prs.person_id = p.person_id AND prs.voided = 0
                    WHERE  pbd.place_of_birth = (SELECT location_id FROM location WHERE name = '#{k}') AND DATE(pbd.date_registered) BETWEEN '#{start_date}' AND '#{end_date}' AND p.gender = 'F'
                    AND prs.status_id IN (#{status_ids})
                    GROUP BY p.gender, pbd.birth_registration_type_id
                  "
        ).as_json.last['total'] rescue 0
        place_of_birth[k]['Female']  = female

    end

    total = {"Total" =>{"Male" => total_male, "Female" => total_female}}.as_json

    data = {
      'Registration Types' => reg_type.as_json,
      'Parents Married'    => parents_married.as_json,
      'Delayed Registrations' => delayed.as_json,
      'Place of Birth' => place_of_birth.as_json,
      "#{status}" => total.as_json
     }
    data
  end
  def self.by_status(status, start_date,end_date)
    

  end
end
