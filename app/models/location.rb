class Location < ActiveRecord::Base
  self.table_name = :location
  self.primary_key = :location_id
  include EbrsAttribute

  has_many :users
  
  cattr_accessor :current_district
  cattr_accessor :current_health_facility
    

end
