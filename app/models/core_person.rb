class CorePerson < ActiveRecord::Base
    self.table_name = "core_person"
    self.primary_key = "person_id"
    has_one :user
    belongs_to :person_type
    has_one :person_name, foreign_key: "person_id"
end
