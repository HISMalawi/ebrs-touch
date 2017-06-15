class Role < ActiveRecord::Base

    include EbrsAttribute
    self.table_name = :role
    self.primary_key = :role_id
    has_one :user_role

end
