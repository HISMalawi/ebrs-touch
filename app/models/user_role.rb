class UserRole < ActiveRecord::Base

    include EbrsAttribute
    self.table_name = :user_role
    self.primary_key = :user_role_id
    belongs_to :user, :foreign_key => :user_id
    belongs_to :role, :foreign_key => :role_id
end
