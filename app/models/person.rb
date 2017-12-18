class Person < ActiveRecord::Base
    self.table_name = :person
    self.primary_key = :person_id
    belongs_to :core_person, foreign_key: "person_id"
    has_many :person_names
    include EbrsAttribute


    def addresses
      PersonAddress.where(person_id: self.id)
    end

    def mother
      result = nil
      relationship_type = PersonRelationType.find_by_name("Mother")

      relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
      unless relationship.blank?
        result = Person.where(:person_id => relationship.person_b).last
      end

      result
    end

    def mother_all
      result = nil
      relationship_type = PersonRelationType.find_by_name("Adoptive-Mother")
      relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last

      if relationship.blank?
        relationship_type = PersonRelationType.find_by_name("Mother")
        relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
      end

      unless relationship.blank?
        result = Person.where(:person_id => relationship.person_b).last
      end

      result
    end

    def father_all
      result = nil
      relationship_type = PersonRelationType.find_by_name("Adoptive-Father")
      relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last

      if relationship.blank?
        relationship_type = PersonRelationType.find_by_name("Father")
        relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
      end

      unless relationship.blank?
        result = Person.where(:person_id => relationship.person_b).last
      end

      result
    end

    def adoptive_mother
      result = nil
      relationship_type = PersonRelationType.find_by_name("Adoptive-Mother")

      relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
      unless relationship.blank?
        result = Person.where(:person_id => relationship.person_b).last
      end

      result
    end

    def father
      result = nil
      relationship_type = PersonRelationType.find_by_name("Father")

      relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
      unless relationship.blank?
        result = Person.where(:person_id => relationship.person_b).last
      end

      result
    end

    def adoptive_father
      result = nil
      relationship_type = PersonRelationType.find_by_name("Adoptive-Father")

      relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
      unless relationship.blank?
        result = Person.where(:person_id => relationship.person_b).last
      end

      result
    end

    def informant
      result = nil
      relationship_type = PersonRelationType.find_by_name("Informant")

      relationship = PersonRelationship.where(:person_a => self.person_id, :person_relationship_type_id => relationship_type.id).last
      unless relationship.blank?
        result = Person.where(:person_id => relationship.person_b).last
      end

      result
    end

    def citizenship
      adr = PersonAddress.where(person_id: self.id).last
      loc_name = Location.find(adr.citizenship).country  rescue nil
      loc_name
    end

    def name
      name = self.person_names.last
      "#{name.first_name} #{name.middle_name} #{name.last_name}".gsub(/\s+/, ' ')
    end

    def first_name
      self.person_names.last.first_name
    end

    def middle_name
      self.person_names.last.middle_name
    end

    def last_name
      self.person_names.last.last_name
    end


    def full_gender
      {'M' => 'Male', 'F' => 'Female'}[self.gender]
    end
    
    def loc_map(id, tag=nil)
      tag_id = LocationTag.where(name: tag).last.id rescue nil
      result = nil
      if tag_id.blank?
        result = Location.find(id).name rescue nil
      else
        tagmap = LocationTagMap.where(location_tag_id: tag_id, location_id: id).last rescue nil
        if tagmap
          result = Location.find(tagmap.location_id).name rescue nil
        end
      end
  
      result
    end

    def place_of_birth
      PersonBirthDetail.find_by_person_id(self.id).birth_place.name
    end   

    def hospital_of_birth
       self.loc_map(PersonBirthDetail.find_by_person_id(self.id).birth_location_id, "Health Facility")
    end  

    def birth_ta

    end  

    def birth_village

    end  

    def birth_district

    end
    
    def dob
      if self.birthdate_estimated.to_s == 0 && self.birthdate != "1900-01-01"
        return self.birthdate.to_date.strftime("%d/%b/%Y")
      end
    end

    def get_attribute(type)
      type_id = PersonAttributeType.where(name: type).last.id rescue nil
      PersonAttribute.where(person_id: self.person_id, person_attribute_type_id: type_id, voided: 0).last.value rescue nil
    end
end
