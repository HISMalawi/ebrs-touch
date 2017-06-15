class Location < ActiveRecord::Base
  self.table_name = :location
  self.primary_key = :location_id
  include EbrsAttribute


  has_many  :users
  has_one   :location_tag_map, class_name: 'LocationTagMap', foreign_key: 'location_id'
    
  cattr_accessor :current_district
  cattr_accessor :current_health_facility
  cattr_accessor :current
    
  def district
    if self.parent_location.blank?
      return self 
    else
      if self.location_tag_map.location_tag.name.match(/Health facility/i)
        return Location.find(self.parent_location)
      else
        return nil
      end
    end

  end

end
