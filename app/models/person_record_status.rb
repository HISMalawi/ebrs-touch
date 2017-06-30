class PersonRecordStatus < ActiveRecord::Base
    self.table_name = :person_record_statuses
    self.primary_key = :person_record_status_id
    include EbrsAttribute

    belongs_to :person, foreign_key: "person_id"
    belongs_to :status, foreign_key: "status_id"

  def self.new_record_state(person_id, state, change_reason='')
    state_id = Status.where(:name => state).first.id
    self.create(
        person_id: person_id,
        status_id: state_id,
        creator: User.current.id,
        comments: change_reason
    )
  end
end
