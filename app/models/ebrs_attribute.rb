class Pusher <  CouchRest::Model::Base
  configs = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
  connection.update({
                        :protocol => "#{configs['protocol']}",
                        :host     => "#{configs['host']}",
                        :port     => "#{configs['port']}",
                        :prefix   => "#{configs['prefix']}",
                        :suffix   => "#{configs['suffix']}",
                        :join     => '_',
                        :username => "#{configs['username']}",
                        :password => "#{configs['password']}"
                    })
end

module EbrsAttribute

  def send_data(hash)
    raw_id = hash.id
    hash = hash.as_json
    hash.each {|k, v|
      hash[k] = v.to_s(:db) if (['Time', 'Date', 'Datetime'].include?(v.class.name))
    }

    district_id = nil
    location_id = nil
    person_id = hash['person_id']
    person_id = hash['person_a'] if person_id.blank?
    person_id = PersonName.where(person_name_id: hash['person_name_id']).first.person_id rescue nil if person_id.blank?
    person_id = User.where(user_id: hash['user_id']).first.person_id rescue nil if person_id.blank?

    created_at = PersonBirthDetail.where(person_id: person_id).last.location_created_at rescue nil

    if !created_at.blank?
      district_id = Location.find(created_at).parent_location rescue nil
      district_id = created_at if district_id.blank?
    end

    if !person_id.blank?
      district_id = Pusher.database.get(person_id)['district_id'] rescue nil if district_id.blank?
      location_id = created_at.present? ? created_at : (Pusher.database.get(person_id)['location_id'] rescue nil)
    end
    if district_id.blank?
      district_id = SETTINGS['application_mode'] == 'FC' ? Location.find(SETTINGS['location_id']).parent_location : SETTINGS['location_id']
    end

    location_id = (SETTINGS['location_id']) if location_id.blank?
    h = Pusher.database.get(person_id.to_s) rescue nil

    if h.present?

      h['location_id'] = location_id || h['location_id'] || SETTINGS['location_id']
      h['district_id'] = district_id
      data = h[self.class.table_name]
      if data.blank?
        data = Hash.new
      end

      data["#{raw_id}"] = hash
      h[self.class.table_name] = data
    else

      data = Hash.new
      data["#{raw_id}"] = hash

      temp_hash = {
          '_id' => person_id.to_s,
          'type' => 'data',
          'location_id' => location_id,
          'district_id' => district_id,
          self.class.table_name =>  data
      }
      h = temp_hash
    end
    port=    YAML.load_file(Rails.root.join('config','couchdb.yml'))[Rails.env]['port']
    adrs= Socket.ip_address_list.reject{|a| a.inspect.match(/127.0.0.1|0.0.0.0|localhost/) }.collect{|ip|
      "#{ip.ip_address}:#{port}"}.reject{|ip| !ip.match(/\d+\.\d+\.\d+\.\d+\:\d+/)}

    h['change_agent'] = self.class.table_name
    h['change_location_id'] = SETTINGS['location_id']
    h['ip_addresses'] = adrs

    Pusher.database.save_doc(h)
  end

  def self.included(base)
    base.class_eval do
      before_create :check_record_complteness_before_creating
      before_save :check_record_complteness_before_updating, :keep_prev_value
      before_create :generate_key
      #after_create :create_or_update_in_couch
      #after_create :create_audit_trail_after_create
      after_save :create_or_update_in_couch#, :create_audit_trail
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
    send_data(self)
  end

  def create_audit_trail

    if !["audit_trails","person_name_code","core_person","person_record_status"].include? self.class.table_name
      if self.prev.present?
        fields = self.attributes.keys
        prev = self.prev
        fields.each do |key|
          next if ["created_at"].include? key
          next if key.include? "password"
          if prev[key] != self.attributes[key]
            AuditTrail.create(table_name: self.class.table_name,
                              table_row_id:self.id,
                              person_id: (self.person_id rescue (self.person.person_id rescue (self.user_id rescue self.person_a))),
                              previous_value: prev[key],
                              field: key,
                              current_value: self.attributes[key],
                              audit_trail_type_id: AuditTrailType.find_by_name("UPDATE").id,
                              comment: "#{self.class.table_name.humanize} record updated")
          else
            next
          end
        end
      else
        AuditTrail.create(table_name: self.class.table_name,
                          table_row_id:self.id,
                          person_id: (self.person_id rescue (self.person.person_id rescue (self.user_id rescue self.person_a))),
                          audit_trail_type_id: AuditTrailType.find_by_name("CREATE").id,
                          comment: "#{self.class.table_name.humanize} record created")
      end
    end
  end
  def create_method( name, &block )
    self.class.send(:define_method, name, &block )
  end

  def create_attr( name )
    create_method( "#{name}=".to_sym ) { |val|
      instance_variable_set( "@" + name, val)
    }

    create_method( name.to_sym ) {
      instance_variable_get( "@" + name )
    }
  end
  def keep_prev_value
    self.create_attr("prev")
    self.prev = nil
    if self.class.table_name =="person_name"
      last_name = ActiveRecord::Base.connection.select_all("SELECT * FROM person_name WHERE person_id=#{self.person_id} ORDER BY updated_at").last rescue nil
      if last_name.present?
        self.prev = self.class.new(last_name)
      else
        self.prev = nil
      end
    else
      self.prev = self.class.find(self.id) rescue nil
    end
  end
  def create_audit_trail_after_update
    if self.class.table_name != "audit_trails"
      AuditTrail.create(table_name: self.class.table_name,
                        table_row_id:self.id,
                        person_id: (self.person_id rescue (self.person.person_id rescue self.user_id)),
                        audit_trail_type_id: AuditTrailType.find_by_name("UPDATE").id,
                        comment: "#{self.class.table_name.humanize} record created")
    end
  end


end
