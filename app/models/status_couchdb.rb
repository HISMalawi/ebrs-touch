require 'couchrest_model'
class StatusCouchdb < CouchRest::Model::Base
  property :status_id, Integer
  property :name, String
  property :description, String

  timestamps!

  design do
    view :by_status_id
    view :by_name
    view :by_description
  end

end
