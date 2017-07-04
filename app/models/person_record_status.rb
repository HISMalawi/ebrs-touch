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
      if state.voided != 1
        state.voided = 1
        state.date_voided = Time.now
        state.voided_by = User.current.id
        state.save
      end
    end

    self.create(
        person_id: person_id,
        status_id: state_id,
        voided: 0,
        creator: User.current.id,
        comments: change_reason
    )
  end
end
