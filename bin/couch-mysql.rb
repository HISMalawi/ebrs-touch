
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

class Methods
  def self.update_doc(doc)
    `bundle exec rails runner bin/save_from_couch.rb '#{doc.to_json}'`
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

