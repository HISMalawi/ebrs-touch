class PersonName < ActiveRecord::Base
    self.table_name = :person_name
    self.primary_key = :person_name_id
    belongs_to :core_person, :foreign_key: "person_id"
    has_one :person_name_code, :foreign_key: "person_name_id"
end
