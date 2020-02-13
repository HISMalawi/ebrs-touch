class PersonIdentifier < ActiveRecord::Base
    include EbrsAttribute
    self.table_name = :person_identifiers
    self.primary_key = :person_identifier_id
    belongs_to :core_person, foreign_key: "person_id"
    belongs_to :person_identifier_types, foreign_key: "person_identifier_type_id"

    def self.new_identifier(person_id, type, value)
      type_id = PersonIdentifierType.where(:name => type).first.id
      self.create(
          person_id: person_id,
          person_identifier_type_id: type_id,
          value: value,
          voided: 0
      )
    end

    def self.by_type(person_id, type)
      type_id = PersonIdentifierType.where(name: type).first.id
      PersonIdentifier.where(person_identifier_type_id: type_id,
                             voided: 0, person_id: person_id).first.value rescue nil
    end
end
