class PotentialDuplicate < ActiveRecord::Base
    self.table_name = :potential_duplicates
    self.primary_key = :potential_duplicate_id
    belongs_to :person, foreign_key: "person_id"
    def create_duplicate(id)
    	DuplicateRecord.create(pontetial_duplicate_id: self.id, person_id: id , created_at:(Time.now))
    end
end
