class PersonRelationship < ActiveRecord::Base
    self.table_name = :person_relationship
    self.primary_key = :person_relationship_id
end
