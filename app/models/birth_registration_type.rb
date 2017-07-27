class BirthRegistrationType < ActiveRecord::Base
    self.table_name = :birth_registration_type
    self.primary_key = :birth_registration_type_id
    include EbrsMetadata

    has_many :person_birth_details, foreign_key: "birth_registration_type_id"
end
