Dir["#{Rails.root}/tmp/*"].each do |d|
    next unless d.include?("dispatch-")
    File.foreach(d) do |line|
        next if line.blank?
        PersonRecordStatus.new_record_state(line, "HQ-DISPATCHED", "DC-DISPATCHED")
    end
    `rm #{d}`
end