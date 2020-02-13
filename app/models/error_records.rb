class ErrorRecords < ActiveRecord::Base
    self.table_name = :error_records
    self.primary_key = :id
end
