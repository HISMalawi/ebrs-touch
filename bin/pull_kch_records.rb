require 'csv'

CSV.foreach('/var/www/persons.csv', headers: true) do |pid|
        person_id = pid['person_id']
        #a = PersonService.request_nris_id(person_id, "N/A", 1002792) rescue nil
        a = PersonService.force_sync_remote(person_id) rescue nil
        puts "#{person_id}: #{a}"
end

