require 'couchrest_model'
class RoleCouchdb < CouchRest::Model::Base
  property :role_id, Integer
  property :role, String
  property :level, Integer

  timestamps!

  design do
    view :by_role_id
    view :by_role
    view :by_level
  end
  
end
