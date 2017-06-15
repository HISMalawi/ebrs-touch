class PersonBirthDetail < ActiveRecord::Base
    self.table_name = :person_birth_details
    self.primary_key = :person_birth_details_id
    include EbrsAttribute

    belongs_to :core_person, foreign_key: "person_id"
    has_one :location, foreign_key: "location_id"
    has_one :level_of_education, foreign_key: "level_of_education_id"
    has_one :guardianship, foreign_key: ":guardianship_id"
    has_one :mode_of_delivery, foreign_key: "mode_of_delivery"
    has_one :person_type_of_birth, foreign_key: "person_type_of_birth_id"
end
