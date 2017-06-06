class PersonName < ActiveRecord::Base
    self.table_name = :person_name
    self.primary_key = :person_name_id
    belongs_to :person
    belongs_to :core_person
end
