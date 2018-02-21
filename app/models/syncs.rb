class Syncs < ActiveRecord::Base
    self.table_name = :syncs
    self.primary_key = :sync_id
end
