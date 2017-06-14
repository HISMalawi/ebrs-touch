class User < ActiveRecord::Base
  self.table_name = :users
  self.primary_key = :user_id
  include EbrsAttribute
  default_scope { where(voided: 0) }

  cattr_accessor :current

  belongs_to :core_person, foreign_key: "person_id"
  belongs_to :location
  has_one :user_role

  before_create do |pass|
    self.password = BCrypt::Password.create(self.password) if not self.password.blank?
  end

  before_update do |pass|
    self.password = BCrypt::Password.create(self.password) if not self.password.blank?
  end


end
