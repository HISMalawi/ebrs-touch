class User < ActiveRecord::Base
    self.table_name = :user
    self.primary_key = :user_id
    belongs_to :core_person, foreign_key: "person_id"
    belongs_to :location
    has_one :user_role
end
