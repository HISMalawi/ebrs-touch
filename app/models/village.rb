class Village < ActiveRecord::Base
    self.table_name = :village
    self.primary_key = :village_id
    belongs_to :traditional_authority, foreign_key: "traditional_authority_id"
end
