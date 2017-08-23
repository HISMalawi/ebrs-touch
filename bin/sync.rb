@database = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
locs = PersonBirthDetail.find_by_sql("select distinct location_created_at AS l FROM person_birth_details").map(&:l)
location_id = locs.collect{|l| l.to_s.rjust(5, '0').rjust(6, '1')}.join('_')

source = "#{@database['protocol']}://#{@database['username']}:#{@database['password']}@#{@database['host']}:#{@database['port']}/#{@database['prefix']}_#{@database['suffix']}"
target = "#{SETTINGS['sync_protocol']}://#{SETTINGS['sync_username']}:#{SETTINGS['sync_password']}@#{SETTINGS['sync_host']}/#{SETTINGS['sync_database']}"
replicator = "#{@database['protocol']}://#{@database['username']}:#{@database['password']}@#{@database['host']}:#{@database['port']}/_replicate"

doc = JSON.parse(`cd #{Rails.root}/db && curl -H 'Content-Type: application/json' -X GET #{source}/_design/MyLocation#{location_id}`)
if doc["error"].present?
`cd #{Rails.root}/db && curl -H 'Content-Type: application/json' -X PUT -d @filters.js #{source}/_design/MyLocation#{location_id}  1>&- 2>&-`
end

doc = JSON.parse(`cd #{Rails.root}/db && curl -H 'Content-Type: application/json' -X GET #{target}/_design/MyLocation#{location_id}`)
if doc["error"].present?
  `cd #{Rails.root}/db && curl -H 'Content-Type: application/json' -X PUT -d @filters.js #{target}/_design/MyLocation#{location_id}  1>&- 2>&-`
end

%x[curl -k -H 'Content-Type: application/json' -X POST -d '#{{
    source: source,
    target: target,
    connection_timeout: 10000,
    retries_per_request: 10,
    http_connections: 30,
    filter: "MyLocation#{location_id}/my_location",
    query_params: {
        location_id: location_id
    },
    continuous: true
}.to_json}' "#{replicator}" 1>&- 2>&-]

if SETTINGS['application_mode'] == 'DC'
    %x[curl -k -H 'Content-Type: application/json' -X POST -d '#{{
        source: target,
        target: source,
        connection_timeout: 10000,
        retries_per_request: 10,
        http_connections: 30,
        filter: "MyLocation#{location_id}/my_location",
        query_params: {
            location_id: location_id
        },
        continuous: true
         }.to_json}' "#{replicator}/_replicate" 1>&- 2>&-]
end




                  
        
                
