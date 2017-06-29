require 'couchrest_model'
class LocationTagCouchdb < CouchRest::Model::Base
  property :location_tag_id, Integer
  property :name, String
  property :description, String

  property :voided, TrueClass, :default => false
  property :void_reason, String
  property :voided_by, Integer
  property :date_voided, Date
  
  timestamps!
  
  design do
    view :by_location_tag_id
    view :by_name
    view :by_description
  end

end
