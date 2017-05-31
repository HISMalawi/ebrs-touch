class PersonAttribute < ActiveRecord::Base
    self.table_name = :person_attributes
    self.primary_key = :person_attribute_id
end
