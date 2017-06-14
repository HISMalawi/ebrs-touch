class TraditionalAuthority < ActiveRecord::Base
    self.table_name = :traditional_authority
    self.primary_key = :traditional_authority_id
    has_many :villages, foreign_key: "traditional_authority_id"
    belongs_to :district, foreign_key: "district_id"
end
