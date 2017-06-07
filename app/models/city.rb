class City < ActiveRecord::Base
    self.table_name = :city
    self.primary_key = :city_id
end
