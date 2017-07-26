
SERVER = CouchRest.new
configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
DB = SERVER.database!("#{configs['prefix']}_#{configs['suffix']}")

class Pusher < CouchRest::Document
  use_database(DB)
end

module EbrsAttribute

  def send_data(hash)
    if !hash['document_id'].blank?
      h = Pusher.database.get(hash['document_id'])
      hash.keys.each do |k|
        h[k] = hash[k]
      end
    else
      h = Pusher.new(hash)
    end

    h.save
    h['document_id'] = h.id
    h.save

    h.id
  end

  def self.included(base)
    base.class_eval do
      before_create :check_record_complteness_before_creating
      before_save :check_record_complteness_before_updating
      before_create :generate_key
      after_create :create_or_update_in_couch
      after_save :create_or_update_in_couch
    end
  end

  def check_record_complteness_before_creating
    self.creator = User.current.id if self.attribute_names.include?("creator") \
    and (self.creator.blank? || self.creator == 0)and User.current != nil
    self.provider_id = User.current.person.id if self.attribute_names.include?("provider_id") and \
      (self.provider_id.blank? || self.provider_id == 0)and User.current != nil
    self.created_at = Time.now if self.attribute_names.include?("created_at")
    self.updated_at = Time.now if self.attribute_names.include?("updated_at")
    self.uuid = ActiveRecord::Base.connection.select_one("SELECT UUID() as uuid")['uuid'] \
      if self.attribute_names.include?("uuid")
    self.voided = false if self.attribute_names.include?("voided") and (self.voided.to_s.blank? rescue true)
  end

  def check_record_complteness_before_updating
    self.changed_by = User.current.id if self.attribute_names.include?("changed_by") and (self.creator.blank? || self.creator == 0)and User.current != nil
    self.changed_at = Time.now if self.attribute_names.include?("changed_at")
  end

  def next_primary_key
    max = (ActiveRecord::Base.connection.select_all("SELECT MAX(#{self.class.primary_key}) FROM #{self.class.table_name}").last.values.last.to_i rescue 0)
    return (max + 1) unless ['person_id', 'user_id'].include?(self.class.primary_key)
    max = (SETTINGS['location_id'].ljust(5, '0') rescue 0) + ((max.to_s.split('')[5 .. 1000].join('').to_i rescue 0) + 1)
    max
  end

  def generate_key
    if !self.class.primary_key.blank? && !self.class.primary_key.class.to_s.match('CompositePrimaryKeys')
      eval("self.#{self.class.primary_key} = next_primary_key") if self.attributes[self.class.primary_key].blank?
    end
  end

  def create_or_update_in_couch
    data = self
    transformed_data = data.as_json
    #transformed_data.delete("#{eval(data.class.name).primary_key}")
    transformed_data['type'] = eval(data.class.name).table_name
    doc_id = send_data(transformed_data)
    if data.document_id.blank?
      data.update_attributes(:document_id => doc_id)
    end
  end
end
