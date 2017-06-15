class IdentifierAllocationQueue < ActiveRecord::Base
    self.table_name = :identifier_allocation_queue
    self.primary_key = :identifier_allocation_queue_id
    include EbrsAttribute

    belongs_to :core_person, foreign_key: "person_id"
    
end
