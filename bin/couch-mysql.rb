
require 'couch_tap'
require "yaml"
require 'mysql2'
require 'rails'

couch_mysql_path = Dir.pwd + "/config/couchdb.yml"
db_settings = YAML.load_file(couch_mysql_path)

couch_db_settings = db_settings["production"]

couch_protocol = couch_db_settings["protocol"]
couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = "#{couch_db_settings["prefix"]}_#{couch_db_settings["suffix"]}"
couch_port = couch_db_settings["port"]


couch_mysql_path = Dir.pwd + "/config/database.yml"
db_settings = YAML.load_file(couch_mysql_path)
mysql_db_settings = db_settings["production"]

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
  :database => mysql_db
)
class Methods
  def self.update_doc(doc)
    client = $client
    client.query("SET FOREIGN_KEY_CHECKS = 0")
    table = doc['type']
    doc_id = doc['document_id']
    return nil if doc_id.blank?
    rows = client.query("SELECT * FROM #{table} WHERE document_id = '#{doc_id}' LIMIT 1").each(:as => :hash)
    data = doc.reject{|k, v| ['_id', '_rev', 'type'].include?(k)}

    if !rows.blank?
      update_query = "UPDATE #{table} SET "
      data.each do |k, v|
        if k.match(/updated_at|created_at|date/)
          v = v.to_datetime.to_s(:db) rescue v
        end

        update_query += " #{k} = \"#{v}\", "
      end
      update_query = update_query.strip.sub(/\,$/, '')
      update_query += " WHERE document_id = '#{doc_id}' "
      out = client.query(update_query) rescue (raise table.to_s)
    else
      insert_query = "INSERT INTO #{table} ("
      keys = []
      values = []

      data.each do |k, v|
        
        if k.match(/updated_at|created_at|changed_at|date/)
          v = v.to_datetime.to_s(:db) rescue v
        end
        keys << k
        values << v
      end

      insert_query += (keys.join(', ') + " ) VALUES (" )
      insert_query += ( "\"" + values.join( "\", \"")) + "\")"
      client.query(insert_query) rescue (raise insert_query.to_s)
    end
    client.query("SET FOREIGN_KEY_CHECKS = 1")
  end
end

changes "http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}" do
  # Which database should we connect to?
  database "#{mysql_adapter}://#{mysql_username}:#{mysql_password}@#{mysql_host}:#{mysql_port}/#{mysql_db}"
  #StatusCouchdb Document Type

  document 'type' => 'birth_registration_type' do |doc|
     output = Methods.update_doc(doc.document)
  end
  document 'type' => 'core_person' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'level_of_education' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'location' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'location_tag' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'location_tag_map' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'mode_of_delivery' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_addresses' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'guardianship' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_attribute_types' do |doc|
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
  document 'type' => 'person_record_statuses' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_relationship' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_identifiers' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_identifier_types' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_attributes' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_attribute_types' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_relationship_types' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_type' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'person_type_of_births' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'role' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'statuses' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'user_role' do |doc|
    output = Methods.update_doc(doc.document)
  end
  document 'type' => 'users' do |doc|
    output = Methods.update_doc(doc.document)
  end
end

