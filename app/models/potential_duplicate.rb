class PotentialDuplicate < ActiveRecord::Base
    self.table_name = :potential_duplicates
    self.primary_key = :potential_duplicate_id
    belongs_to :person, foreign_key: "person_id"
end
