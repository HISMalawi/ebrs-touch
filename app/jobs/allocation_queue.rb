class AllocationQueue
  include SuckerPunch::Job
  workers 1

  def perform()

    FileUtils.touch("#{Rails.root}/public/sentinel")

    ActiveRecord::Base.logger.level = 1
    queue = []
    queue = IdentifierAllocationQueue.where(assigned: 0) if (SETTINGS['assign_ben'] != false)

    if queue.length > 0
      SuckerPunch.logger.info "Approving for #{queue.count} record(s)"
    end

    begin
      (queue || []).each do |record|

        person_birth_detail = PersonBirthDetail.where(person_id: record.person_id).first
        brn = person_birth_detail.national_serial_number
        ben = person_birth_detail.district_id_number
        fsn = person_birth_detail.facility_serial_number

        if record.person_identifier_type_id == PersonIdentifierType.where(
            :name => "Birth Entry Number").last.person_identifier_type_id
          if !ben.blank?
            record.update_attributes(assigned: 1)
            next
          end

          location = Location.find(SETTINGS['location_id'])
          district_code = location.code
          district_code_len = district_code.length
          year = Date.today.year
          year_len = year.to_s.length

          last = PersonBirthDetail.where("LEFT(district_id_number, #{district_code_len}) = '#{district_code}'
            AND RIGHT(district_id_number, #{year_len}) = #{Date.today.year}").select(" MAX(SUBSTR(district_id_number,
              #{(district_code_len + 2)}, 7)) AS last_num")[0]['last_num'] rescue 0

          mid_number = (last.to_i + 1).to_s.rjust(7,'0')

          person_birth_detail.update_attributes(district_id_number: "#{district_code}/#{mid_number}/#{year}")
          record.update_attributes(assigned: 1)
          PersonRecordStatus.new_record_state(record.person_id, 'HQ-ACTIVE', '', queue.creator)
          PersonIdentifier.new_identifier(record.person_id, 'Birth Entry Number', person_birth_detail.district_id_number)

        elsif record.person_identifier_type_id == PersonIdentifierType.where(
            :name => "Birth Registration Number").last.person_identifier_type_id
          if !brn.blank?
            record.update_attributes(assigned: 1)
            next
          end


          last = (PersonBirthDetail.select(" MAX(national_serial_number) AS last_num")[0]['last_num'] rescue 0).to_i
          brn = last + 1
          person_birth_detail.update_attributes(national_serial_number: brn)
          record.update_attributes(assigned: 1)
          PersonRecordStatus.new_record_state(record.person_id, 'HQ-PRINT')

          PersonIdentifier.new_identifier(record.person_id, 'Birth Registration Number', person_birth_detail.national_serial_number)

        elsif record.person_identifier_type_id == PersonIdentifierType.where(
            :name => "Facility number").last.person_identifier_type_id
          if !fsn.blank?
            record.update_attributes(assigned: 1)
            next
          end

          if SETTINGS['location_id'] && SETTINGS['location_id'] == 'FC'
            last = (PersonBirthDetail.where(location_created_at: SETTINGS['location_id']).select(" MAX(facility_serial_number) AS last_num")[0]['last_num'] rescue 0).to_i
            num = last + 1

            person_birth_detail.update_attributes(facility_serial_number: num)
            record.update_attributes(assigned: 1)

            PersonIdentifier.new_identifier(record.person_id, 'Facility Number', person_birth_detail.facility_serial_number)
          end
        end
      end
    rescue
      AllocationQueue.perform_in(1.5)
    end

    AllocationQueue.perform_in(1.5)
  end

end
