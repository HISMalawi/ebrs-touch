class District < ActiveRecord::Base
    self.table_name = :district
    self.primary_key = :district_id

    #belongs_to :region, foreign_key: "region_id"
    has_many :traditional_authorities, foreign_key: "district_id"
end
