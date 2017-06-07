class PersonRelationType < ActiveRecord::Base
    self.table_name = :person_relationship_type
    self.primary_key = :person_relationship_type_id
end
