class Person < ActiveRecord::Base
    self.table_name = :person
    self.primary_key = :person_id
<<<<<<< HEAD
    belongs_to :core_person, foreign_key: "person_id"
=======
    has_many :users
    has_many :person_names
>>>>>>> 16609b25dcc8d3e2fb9e8f2198147c0e295858cb
end
