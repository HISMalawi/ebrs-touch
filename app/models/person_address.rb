class PersonAddress < ActiveRecord::Base
    self.table_name = :person_address
    self.primary_key = :person_addresses_id
end
