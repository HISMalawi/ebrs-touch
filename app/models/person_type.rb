class PersonType < ActiveRecord::Base
    self.table_name = :person_type
    self.primary_key = :person_type_id
    has_many :core_persons
end
