class AllocationQueue
 include SuckerPunch::Job
  workers 1

  def perform()
    queue = IdentifierAllocationQueue.where(assigned: 0)

    SuckerPunch.logger.info "Approving for #{queue.count} record(s)"

    begin
      (queue || []).each do |record|
        if record.identifier_type == 'BEN'
          district_code = Location.current_district.code rescue 'BLK'
          district_code_len = district_code.length
          year = Date.today.year
          year_len = year.to_s.length

          count = PersonBirthDetail.where("LEFT(district_id_number, #{district_code_len}) = '#{district_code}'
            AND RIGHT(district_id_number, #{year_len}) = #{Date.today.year}").count

          mid_number = (count + 1).to_s.rjust(7,'0')
          person_birth_detail = PersonBirthDetail.where(person_id: record.person_id).first
          person_birth_detail.update_attributes(district_id_number: "#{district_code}/#{mid_number}/#{year}")
          record.update_attributes(assigned: 1)

        elsif record.identifier_type == 'BRN'
        end
      end 
    rescue 
      AllocationQueue.perform_in(1.5)
    end

    AllocationQueue.perform_in(1.5)
  end

end
