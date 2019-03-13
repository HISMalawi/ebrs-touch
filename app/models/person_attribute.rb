class PersonAttribute < ActiveRecord::Base
    self.table_name = :person_attributes
    self.primary_key = :person_attribute_id
    belongs_to :core_person, foreign_key: "person_id"
    belongs_to :person_attribute_type, foreign_key: "person_attribute_type_id"
    include EbrsAttribute

  def self.source_village(person_id)
    loc = nil

    if !self.by_type(person_id, "Village Headman Name").blank?
      d = PersonBirthDetail.where(person_id: person_id).first
      loc = Location.find(d.location_created_at).name rescue nil
    end

    loc
  end

  def self.by_type(person_id, type)
    value = nil

    type = PersonAttributeType.where(name: type).first

    if !type.blank?
      tp = PersonAttribute.where(person_id: person_id, person_attribute_type_id: type.id, voided: 0).first
      value = tp.value unless tp.blank?
    end

    value
  end
end
