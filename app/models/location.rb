class Location < ActiveRecord::Base
  self.table_name = :location
  self.primary_key = :location_id
  include EbrsAttribute
  
  has_many :users

end
