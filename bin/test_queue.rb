status_id     = Status.where(name: "DC-COMPLETE").last.status_id
id_type_id    = PersonIdentifierType.where(:name => "Birth Entry Number").last.person_identifier_type_id
person_ids    = PersonRecordStatus.where(status_id: status_id, voided: 0).map(&:person_id).uniq[ARGV[0].to_i .. (ARGV[0].to_i + 99)]

#person_ids    = File.read("person_ids").split(',')[ARGV[0].to_i .. (ARGV[0].to_i + 99)]
user_id       = User.where(username: "admin279").first.id

person_ids.each_with_index do |pid, i|
puts pid

  allocate_record = IdentifierAllocationQueue.new
  allocate_record.person_id = pid
  allocate_record.assigned = 0
  allocate_record.creator = user_id
  allocate_record.person_identifier_type_id = id_type_id
  allocate_record.created_at = Time.now
  if allocate_record.save
    PersonRecordStatus.new_record_state(pid, 'HQ-ACTIVE', "", user_id)
  end
end

