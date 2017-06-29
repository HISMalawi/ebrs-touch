require 'couchrest_model'
class PersonTypeOfBirthsCouchdb < CouchRest::Model::Base
  property :person_type_of_birth_id, Integer
  property :name, String
  property :description, String
  
  property :voided, TrueClass, :default => false
  property :void_reason, String
  property :voided_by, Integer
  property :date_voided, Date

  timestamps!

  design do
    view :by_person_type_id
    view :by_name
    view :by_description
  end
  
end
