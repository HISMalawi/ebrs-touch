require 'couchrest_model'

class LevelOfEducationCouchdb < CouchRest::Model::Base
  property :level_of_education_id, Integer
  property :name, String
  property :description, String
  property :voided, TrueClass, :default => false
  property :void_reason, String
  property :voided_by, Integer
  property :date_voided, Date

  timestamps!

  design do
    view :by_level_of_education_id
    view :by_name
    view :by_name_and_voided
  end
end
