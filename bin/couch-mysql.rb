require 'rest-client'
require "yaml"

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
mysql_port = mysql_db_settings["port"] || '3306'
mysql_adapter = mysql_db_settings["adapter"]
#reading db_mapping


class Methods
  def self.update_doc(doc, seq)
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

      data = doc[change_agent]
      table = change_agent

      p_key = data.keys[0]
      p_value = data[p_key]
      return nil if p_value.blank?

      update_query = " UPDATE "
      data.each do |k, v|
        next if ['null', 'nil'].include?(v)
        next if k.to_s == p_key.to_s
        (!v.blank?) ? (update_query += " #{k} = \"#{v}\", ") :  (update_query += " #{k} = NULL, ")
      end
      update_query = update_query.strip.sub(/\,$/, '')

      insert_query = "INSERT INTO #{table} ("
      keys = []
      values = []

      data.each do |k, v|
        v = (!v.blank?) ? "\"#{v}\"" : " NULL "
        keys << k
        values << v
      end

      insert_query += (keys.join(', ') + " ) VALUES (" )
      insert_query += ( values.join(",")) + ")"
      query = "#{insert_query} ON DUPLICATE KEY #{update_query};"

      open("#{Dir.pwd}/public/query.sql", 'a') do |f|
        f << "#{query}"
      end
    end
  end
end

seq = `mysql -u #{mysql_username} -p#{mysql_password} -h#{mysql_host} #{mysql_db} -e 'SELECT seq FROM couchdb_sequence LIMIT 1'`.split("\n").last rescue nil
changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes?include_docs=true&limit=10000&since=#{seq}"
data = JSON.parse(RestClient.get(changes_link))  rescue {}

seq = 0 if seq.blank?

open("#{Dir.pwd}/public/query.sql","w") do |file|
  file.write('')
end

(data['results'] || []).each do |result|
  seq = result['seq']
  Methods.update_doc(result['doc'], seq)
end


%x[
   mysql -h#{mysql_host} -u#{mysql_username} -p#{mysql_password} -e "SET GLOBAL foreign_key_checks=0"
]
%x[
  mysql -u #{mysql_username} -p#{mysql_password} #{mysql_db} < #{Dir.pwd}/public/query.sql
]
%x[
  mysql -h#{mysql_host} -u#{mysql_username} -p#{mysql_password} -e "SET GLOBAL foreign_key_checks=1"
]

%x[
  mysql -h#{mysql_host} -u#{mysql_username} -p#{mysql_password} #{mysql_db} -e "UPDATE couchdb_sequence SET seq=#{seq}"
]

