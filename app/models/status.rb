class Status < ActiveRecord::Base
    self.table_name = :statuses
    self.primary_key = :status_id
end
