class Status < ActiveRecord::Base
    self.table_name = :statuses
    self.primary_key = :status_id
    has_many :person_record_statuses, foreign_key: "status_id"
end
