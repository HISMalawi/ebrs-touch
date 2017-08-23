
require 'couch_tap'
require "yaml"
require 'mysql2'
require 'rails'

couch_mysql_path = Dir.pwd + "/config/couchdb.yml"
db_settings = YAML.load_file(couch_mysql_path)

settings_path = Dir.pwd + "/config/settings.yml"
settings = YAML.load_file(settings_path)
$app_mode = settings['application_mode']
$app_mode = 'HQ' if $app_mode.blank?

couch_db_settings = db_settings[Rails.env]

couch_protocol = couch_db_settings["protocol"]
couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = "#{couch_db_settings["prefix"]}_#{couch_db_settings["suffix"]}"
couch_port = couch_db_settings["port"]


couch_mysql_path = Dir.pwd + "/config/database.yml"
db_settings = YAML.load_file(couch_mysql_path)
mysql_db_settings = db_settings[Rails.env]

mysql_username = mysql_db_settings["username"]
mysql_password = mysql_db_settings["password"]
mysql_host = mysql_db_settings["host"] || '0.0.0.0'
mysql_db = mysql_db_settings["database"]
mysql_port = mysql_db_settings["port"] || '3306'
mysql_adapter = mysql_db_settings["adapter"]
#reading db_mapping

$client = Mysql2::Client.new(:host => mysql_host,
                             :username => mysql_username,
                             :password => mysql_password,
                             :database => mysql_db,
                             :read_timeout => 60,
                             :write_timeout => 60,
                             :connect_timeout => 60,
                             :reconnect => true
)

class Methods
  def self.qry(runner, query)

    begin
      data = runner.query(query)
    rescue
      sleep(2)
      #reconnect to mysql
      couch_mysql_path = Dir.pwd + "/config/database.yml"
      db_settings = YAML.load_file(couch_mysql_path)
      db_settings = YAML.load_file(couch_mysql_path)
      mysql_db_settings = db_settings[Rails.env]
      mysql_username = mysql_db_settings["username"]
      mysql_password = mysql_db_settings["password"]
      mysql_host = mysql_db_settings["host"] || '0.0.0.0'
      mysql_db = mysql_db_settings["database"]

      runner = Mysql2::Client.new(:host => mysql_host,
                                  :username => mysql_username,
                                  :password => mysql_password,
                                  :database => mysql_db,
                                  :read_timeout => 60,
                                  :write_timeout => 60,
                                  :connect_timeout => 60,
                                  :reconnect => true
      )

      begin
        data = runner.query(query)
      rescue

      end
    end

    data
  end

  def self.update_doc(doc)
    client = $client; table = doc['type']; p_key = doc.keys[2]; p_value = doc[p_key]
    return nil if p_value.blank?
    self.qry(client, "SET FOREIGN_KEY_CHECKS = 0")
    rows = self.qry(client, "SELECT * FROM #{table} WHERE #{p_key} = '#{p_value}' LIMIT 1").each(:as => :hash) rescue []
    data = doc.reject{|k, v| ['_id', '_rev', 'type'].include?(k)}

    if !rows.blank?
      row = rows[0]
      update_query = "UPDATE #{table} SET "
      data.each do |k, v|
        next if ['null', 'nil'].include?(v) && row[k].blank?

        if !v.blank?
          update_query += " #{k} = \"#{v}\", "
        else
          update_query += " #{k} = NULL, "
        end
      end
      update_query = update_query.strip.sub(/\,$/, '')
      update_query += " WHERE #{p_key} = '#{p_value}' "

      self.qry(client, update_query)
    else
      insert_query = "INSERT INTO #{table} ("
      keys = []
      values = []

      data.each do |k, v|

        if !v.blank?
          v = "\"#{v}\""
        else
          v = " NULL "
        end

        keys << k
        values << v

      end

      insert_query += (keys.join(', ') + " ) VALUES (" )
      insert_query += ( values.join(",")) + ")"

      self.qry(client, insert_query)
    end

    self.qry(client, "SET FOREIGN_KEY_CHECKS = 1")
  end
end

changes "http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}" do
  # Which database should we connect to?
  database "#{mysql_adapter}://#{mysql_username}:#{mysql_password}@#{mysql_host}:#{mysql_port}/#{mysql_db}"
  #StatusCouchdb Document Type
  document 'type' => 'core_person' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_addresses' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_attributes' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_birth_details' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_name' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_name_code' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_relationship' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_identifiers' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_record_statuses' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'users' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'user_role' do |doc|
    output = Methods.update_doc(doc.document)
  end
end

