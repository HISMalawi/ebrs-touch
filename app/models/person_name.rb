class PersonName < ActiveRecord::Base
    self.table_name = :person_name
    self.primary_key = :person_name_id
    include EbrsAttribute
    default_scope { where(voided: 0) }

    belongs_to :person
    belongs_to :core_person
    has_one :person_name_code

    after_save :name_codes

    def name_codes
      code = PersonNameCode.where(:person_name_id => self.id).last rescue nil
      code = PersonNameCode.new if code.blank?

      code.person_name_id = self.id
      code.first_name_code  = self.first_name.soundex rescue nil
      code.middle_name_code =  self.middle_name.soundex rescue nil
      code.last_name_code  = self.last_name.soundex rescue nil

      code.save!
    end
end
