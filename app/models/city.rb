class City < ActiveRecord::Base
    self.table_name = :city
    self.primary_key = :city_id
    belongs_to :country, foreign_key: "country_id"
end
