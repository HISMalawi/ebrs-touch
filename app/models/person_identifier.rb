class PersonIdentifier < ActiveRecord::Base
    self.table_name = :person_attribute
    self.primary_key = :person_attribute_id
    belongs_to :core_person, :foreign_key: "person_id"
end
