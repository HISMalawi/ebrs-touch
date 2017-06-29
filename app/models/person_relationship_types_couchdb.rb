require 'couchrest_model'
class PersonRelationshipTypesCouchdb < CouchRest::Model::Base

  property :person_relationship_type_id, Integer
  property :name, String
  property :description, String

  property :voided, TrueClass, :default => false
  property :void_reason, String
  property :voided_by, Integer
  property :date_voided, Date

  timestamps!

  design do
    view :by_person_relationship_type_id
    view :by_name
    view :by_description
  end
end
