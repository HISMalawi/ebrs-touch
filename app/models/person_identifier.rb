class PersonIdentifier < ActiveRecord::Base
    self.table_name = :person_identifiers
    self.primary_key = :person_identifier_id
    belongs_to :core_person, foreign_key: "person_id"
    belongs_to :person_identifier_type, foreign_key: "person_identifier_type_id"
end
