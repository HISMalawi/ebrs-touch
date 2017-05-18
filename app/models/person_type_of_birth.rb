class PersonTypeOfBirth < ActiveRecord::Base
    self.table_name = :person_type_of_births
    self.primary_key = :person_type_of_birth_id
end
