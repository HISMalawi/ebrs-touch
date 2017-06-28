require 'couchrest_model'
class LocationTagMapCouchdb < CouchRest::Model::Base
  property :location_id, Integer
  property :location_tag_id, Integer
  
  design do
    view :by_location_id
    view :by_location_tag_id
    view :by_location_id_and_location_tag_id
  end

end
