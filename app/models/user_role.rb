class UserRole < ActiveRecord::Base
    self.table_name = :user_role
    self.primary_key = :user_role_id
end
