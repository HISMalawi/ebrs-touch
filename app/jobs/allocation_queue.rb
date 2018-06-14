class AllocationQueue
  include SuckerPunch::Job
  workers 1

  def calculate_check_digit(serial_number)

    number = serial_number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2!=parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end

    check_digit = (9 * sum) % 10

    return check_digit
  end

  def perform()

    FileUtils.touch("#{Rails.root}/public/sentinel")

    ActiveRecord::Base.logger.level = 3
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
              #{(district_code_len + 2)}, 8)) AS last_num")[0]['last_num'] rescue 0

          mid_number = (last.to_i + 1).to_s.rjust(8,'0')

          person_birth_detail.update_attributes(district_id_number: "#{district_code}/#{mid_number}/#{year}")
          record.update_attributes(assigned: 1)
          person_birth_detail.update_attributes(date_registered: Date.today)
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

          PersonIdentifier.new_identifier(record.person_id, 'Birth Registration Number', person_birth_detail.national_serial_number)

        elsif record.person_identifier_type_id == PersonIdentifierType.where(
            :name => "Facility number").last.person_identifier_type_id

          if !fsn.blank?
            record.update_attributes(assigned: 1)
            next
          end

          if SETTINGS['location_id'] && SETTINGS['application_mode'] == 'FC'
            code = Location.find(SETTINGS['location_id']).code.squish
            left = "P5#{code}"
            from = left.length + 1
            length = 6

            SuckerPunch.logger.info "111------------ "

            last = (PersonBirthDetail.where(location_created_at: SETTINGS['location_id']).select(" MAX(SUBSTRING(facility_serial_number, #{from}, #{length})) AS last_num")[0]['last_num'] rescue 0).to_i
            num = last + 1
            num =  "%06d" % num
            SuckerPunch.logger.info "#{num} ----- ====="

            checkdigit = calculate_check_digit(num)
            serial_number =  "#{left}#{num}#{checkdigit}"
            SuckerPunch.logger.info "#{serial_number} ----- ====="

            person_birth_detail.update_attributes(facility_serial_number: serial_number)
            record.update_attributes(assigned: 1)

            SuckerPunch.logger.info "Assigned ----- ====="

            p = PersonIdentifier.new
            p.person_id = record.person_id
            p.value = serial_number
            p.person_identifier_type_id = PersonIdentifierType.where(name: "Facility Number").last.id
            p.save
          end
        end
      end
    rescue
      AllocationQueue.perform_in(1.5)
    end

    ActiveRecord::Base.logger.level = 3
    AllocationQueue.perform_in(1.5)
  end

end
