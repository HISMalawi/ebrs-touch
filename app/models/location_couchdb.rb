require 'couchrest_model'
class LocationCouchdb < CouchRest::Model::Base

  property :location_id, Integer
  property :code, String
  property :name, String
  property :description, String
  property :postal_code, String
  property :country, String
  property :latitude, String
  property :longitude, String
  property :county_district, String
  
  property :creator, Integer
  property :voided, TrueClass, :default => false
  property :void_reason, String
  property :voided_by, Integer
  property :date_voided, Date
  property :changed_by, Integer
  property :changed_at, DateTime
  
  timestamps!
  
  design do
    view :by_location_id
    view :by_code
    view :by_name
    view :by_description
    view :by_postal_code
    view :by_country
    view :by_latitude
    view :by_longitude
    view :by_county_district
  end
end
