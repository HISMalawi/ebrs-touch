
SERVER = CouchRest.new
configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
DB = SERVER.database!("#{configs['prefix']}_#{configs['suffix']}")

class Pusher < CouchRest::Document
  use_database(DB)
end

module EbrsAttribute

  def send_data(hash)

    hash.each {|k, v|
      hash[k] = v.to_s(:db) if (['Time', 'Date', 'Datetime'].include?(v.class.name))
    }

    person_id = hash['person_id']
    person_id = hash['person_a'] if person_id.blank?
    person_id = PersonName.find(hash['person_name_id']).person_id rescue nil if person_id.blank? && hash['person_name_id'].present?
    person_id = User.find(hash['user_id']).person_id rescue nil if person_id.blank? && hash['user_id'].present?
    id = person_id.to_s if !person_id.blank?

    return nil if id.blank?

    h = Pusher.database.get(id) rescue nil
    if h.present?
      h[self.class.table_name] = {} if h[self.class.table_name].blank?
      h['location_id'] = SETTINGS['location_id'] if h['location_id'].blank?

      hash.keys.each do |k|
        h[self.class.table_name][k] = hash[k]
      end
    else
      temp_hash = {
          '_id' => id,
          'type' => 'data',
          'location_id' => SETTINGS['location_id'],
          self.class.table_name => hash
      }
      h = Pusher.new(temp_hash)
    end
    h.save
  end

  def self.included(base)
    base.class_eval do
      before_create :check_record_complteness_before_creating
      before_save :check_record_complteness_before_updating
      before_create :generate_key
      #after_create :create_or_update_in_couch
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
    location_pad = SETTINGS['location_id'].to_s.rjust(5, '0').rjust(6, '1')
    max = (ActiveRecord::Base.connection.select_all("SELECT MAX(#{self.class.primary_key})
      FROM #{self.class.table_name} WHERE #{self.class.primary_key} LIKE '#{location_pad}%' ").last.values.last.to_i rescue 0)
    autoincpart = max.to_s.split('')[6 .. 1000].join('').to_i rescue 0
    auto_id = autoincpart + 1
    new_id = (location_pad + auto_id.to_s).to_i
    new_id
  end

  def generate_key
    if !self.class.primary_key.blank? && !self.class.primary_key.class.to_s.match('CompositePrimaryKeys')
      eval("self.#{self.class.primary_key} = next_primary_key") if self.attributes[self.class.primary_key].blank?
    end
  end

  def create_or_update_in_couch
    data = self
    transformed_data = data.as_json
    send_data(transformed_data)
  end
end
