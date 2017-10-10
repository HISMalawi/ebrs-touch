require 'rest-client'
require "yaml"

ActiveRecord::Base.logger.level = 3

couch_mysql_path = Dir.pwd + "/config/couchdb.yml"
db_settings = YAML.load_file(couch_mysql_path)

settings_path = Dir.pwd + "/config/settings.yml"
settings = YAML.load_file(settings_path)
$settings = settings
$app_mode = settings['application_mode']
$app_mode = 'HQ' if $app_mode.blank?

couch_db_settings = db_settings['production']

couch_protocol = couch_db_settings["protocol"]
couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = "#{couch_db_settings["prefix"]}_#{couch_db_settings["suffix"]}"
couch_port = couch_db_settings["port"]


couch_mysql_path = Dir.pwd + "/config/database.yml"
db_settings = YAML.load_file(couch_mysql_path)
mysql_db_settings = db_settings['production']

mysql_username = mysql_db_settings["username"]
mysql_password = mysql_db_settings["password"]
mysql_host = mysql_db_settings["host"] || '0.0.0.0'
mysql_db = mysql_db_settings["database"]

$mysql_username = mysql_db_settings["username"]
$mysql_password = mysql_db_settings["password"]
$mysql_host = mysql_db_settings["host"] || '0.0.0.0'
$mysql_db = mysql_db_settings["database"]
mysql_port = mysql_db_settings["port"] || '3306'
mysql_adapter = mysql_db_settings["adapter"]
#reading db_mapping

$models = {}

Rails.application.eager_load!
ActiveRecord::Base.send(:subclasses).map(&:name).each do |n|
  $models[eval(n).table_name] = n
end


class Methods
  def self.update_doc(doc, seq)
    FileUtils.touch("#{Rails.root}/public/tap_sentinel")

    person_id = doc['_id']
    change_agent = doc['change_agent']

    if doc['change_location_id'].present? && (doc['change_location_id'].to_s != $settings['location_id'].to_s)
      temp = {}
      if !doc['ip_addresses'].blank? && !doc['district_id'].blank?
        data = YAML.load_file("#{Dir.pwd}/public/sites/#{doc['district_id']}.yml") rescue {}
        if data.blank?
          data = {}
        end
        temp = data
        if temp[doc['district_id'].to_i].blank?
          temp[doc['district_id'].to_i] = {}
        end
        temp[doc['district_id'].to_i]['ip_addresses'] = doc['ip_addresses']

        File.open("#{Dir.pwd}/public/sites/#{doc['district_id']}.yml","w") do |file|
          YAML.dump(data, file)
          file.close
        end
      end
      %x[
        mysql -h#{$mysql_host} -u#{$mysql_username} -p#{$mysql_password} -e "SET GLOBAL foreign_key_checks=0"
      ]
      data = doc[change_agent]
      table = change_agent

      p_key = data.keys[0]
      p_value = data[p_key]

      begin
        record = eval($models[table]).find(p_value) rescue nil
        if !record.blank?
          record.update_columns(data)
        else
          record =  eval($models[table]).new(data)
          record.save
        end
      rescue
        sleep(1)
        begin
        record = eval($models[table]).find(p_value) rescue nil
          if !record.blank?
            record.update_columns(data)
          else
            record =  eval($models[table]).new(data)
            record.save
          end
        rescue => e
          id = "#{table}_#{p_value}_#{seq}"
          open("#{Dir.pwd}/public/errors/#{id}", 'a') do |f|
            f << "#{record}"
            f << "\n\n#{e}"
          end
        end
      end

      %x[
        mysql -h#{$mysql_host} -u#{$mysql_username} -p#{$mysql_password} -e "SET GLOBAL foreign_key_checks=1"
      ]
    end
  end
end

seq = `mysql -u #{mysql_username} -p#{mysql_password} -h#{mysql_host} #{mysql_db} -e 'SELECT seq FROM couchdb_sequence LIMIT 1'`.split("\n").last rescue nil

seq = 0 if seq.blank?

changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes?include_docs=true&limit=1000&since=#{seq}"

data = JSON.parse(RestClient.get(changes_link))  rescue {}

(data['results'] || []).each do |result|
  seq = result['seq']
  Methods.update_doc(result['doc'], seq)
end

#RESOLVE PREVIOUS ERRORS
errored = Dir.entries("#{Rails.root}/public/errors/")
(errored || []).each do |e|
  s = e.split(/\_/).last
  next if !s.match(/\d+/)
  s = s.to_i - 1

  changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes?include_docs=true&since=#{s}&limit=1"
  record = JSON.parse(RestClient.get(changes_link))['results'].last['doc']  rescue {}
  table_name = record['change_agent']
  data = record[table_name]
  p_key = data.keys.first rescue next
  p_value = data[p_key]

  record = eval($models[table_name]).find(p_value) rescue nil
  if !record.blank?
    record.update_columns(data)
  else
    record =  eval($models[table_name]).new(data)
    if record.save
      `rm #{Rails.root}/public/errors/#{e}`
    end
  end

  %x[
    mysql -h#{$mysql_host} -u#{$mysql_username} -p#{$mysql_password} -e "SET GLOBAL foreign_key_checks=1"
  ]
end

=begin

%x[
   mysql -h#{mysql_host} -u#{mysql_username} -p#{mysql_password} -e "SET GLOBAL foreign_key_checks=0"
]
%x[
  mysql -u #{mysql_username} -p#{mysql_password} #{mysql_db} < #{Dir.pwd}/public/query.sql
]
%x[
  mysql -h#{mysql_host} -u#{mysql_username} -p#{mysql_password} -e "SET GLOBAL foreign_key_checks=1"
]
=end

%x[
  mysql -h#{mysql_host} -u#{mysql_username} -p#{mysql_password} #{mysql_db} -e "UPDATE couchdb_sequence SET seq=#{seq}"
]

ActiveRecord::Base.logger.level = 1

CouchSQL.perform_in(2)