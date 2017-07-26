class PersonIdentifier < ActiveRecord::Base
    self.table_name = :person_identifiers
    self.primary_key = :person_identifier_id
    belongs_to :core_person, foreign_key: "person_id"
<<<<<<< HEAD
    include EbrsAttribute
    belongs_to :person_identifier_type, foreign_key: "person_identifier_type_id"
end
=======
    belongs_to :person_identifier_types, foreign_key: "person_identifier_type_id"
end
>>>>>>> 1ce3221228c5a0b22ff2ae17bd964665a65c0862
