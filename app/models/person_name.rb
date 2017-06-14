class PersonName < ActiveRecord::Base
    self.table_name = :person_name
    self.primary_key = :person_name_id
    include EbrsAttribute

    belongs_to :person
    belongs_to :core_person
    has_one :person_name_code
end
