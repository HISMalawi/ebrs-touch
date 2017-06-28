require 'couchrest_model'
class ModeOfDeliveryCouchdb < CouchRest::Model::Base
  property :mode_of_delivery_id, Integer
  property :name, String
  property :description, String

  property :voided, TrueClass, :default => false
  property :void_reason, String
  property :voided_by, Integer
  property :date_voided, Date
  
  timestamps!
  
  design do
    view :by_mode_of_delivery_id
    view :by_name
    view :by_description
  end
  
end
