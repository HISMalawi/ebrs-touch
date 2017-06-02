class Village < ActiveRecord::Base
    self.table_name = :village
    self.primary_key = :village_id
end
