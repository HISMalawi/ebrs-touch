class PersonRecordStatus < ActiveRecord::Base
    self.table_name = :person_record_statuse
    self.primary_key = :person_record_status_id
    belongs_to :core_person, :foreign_key: "person_id"
end
