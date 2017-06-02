class CorePerson < ActiveRecord::Base
    self.table_name = :core_person
    self.primary_key = :person_id
end
