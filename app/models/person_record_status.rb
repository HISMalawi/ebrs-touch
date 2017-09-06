class PersonRecordStatus < ActiveRecord::Base
    self.table_name = :person_record_statuses
    self.primary_key = :person_record_status_id
    include EbrsAttribute

    belongs_to :person, foreign_key: "person_id"
    belongs_to :status, foreign_key: "status_id"

  def self.new_record_state(person_id, state, change_reason='')
    state_id = Status.where(:name => state).first.id
    trail = self.where(:person_id => person_id)
    trail.each do |state|
      state.voided = 1
      state.date_voided = Time.now
      state.voided_by = User.current.id
      state.save
    end

    self.create(
        person_id: person_id,
        status_id: state_id,
        voided: 0,
        creator: User.current.id,
        comments: change_reason
    )
  end

  def self.status(person_id)
    self.where(:person_id => person_id, :voided => 0).last.status.name
  end

  def self.stats(types=['Normal', 'Adopted', 'Orphaned', 'Abandoned'], approved=true)
    result = {}
    birth_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

    Status.all.each do |status|
      result[status.name] = self.find_by_sql("
      SELECT COUNT(*) c FROM person_record_statuses s
        INNER JOIN person_birth_details p ON p.person_id = s.person_id
          AND p.birth_registration_type_id IN (#{birth_type_ids.join(', ')})
        WHERE voided = 0 AND status_id = #{status.id} GROUP BY person_id")[0]['c']
    end

    unless approved == false
      excluded_states = ['HQ-REJECTED'].collect{|s| Status.find_by_name(s).id}
        included_states = Status.where("name like 'HQ-%' ").map(&:status_id)

      result['APPROVED BY ADR'] =  self.find_by_sql("
        SELECT COUNT(*) c FROM person_record_statuses
        WHERE voided = 0 AND status_id NOT IN (#{excluded_states.join(', ')}) AND status_id IN (#{included_states.join(', ')})")[0]['c']
    end
    result
  end
end
