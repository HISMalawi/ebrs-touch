require 'csv'

Source_path = '/home/comish/Desktop/datamigration'


def seedLocation
  
 puts "seeding location data..." 

 CSV.foreach("#{Source_path}/openmrs_locationtbl.csv", :headers => true) do |row|

      
       uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF
   next if row['name'].blank?

      Location.create(name: row['name'], description: "#{row['description']}")
        
 end

 puts ""
 puts "Location data seeded!"
  
end


def seedLocationTag

 puts "seeding location_tag data..."

 CSV.foreach("#{Source_path}/openmrs_locationtagTbl.csv", :headers => true) do |row|

  
       uuid = ActiveRecord::Base.connection.select_one <<EOF
          select uuid();
EOF
  
  next if row['name'].blank?
    
      LocationTag.create(name: row['name'], description: row['description'])
        
 end
 
 puts ""  
 puts "LocationTag table seeded!"

end

def seedLocationTagMap
      
 puts "seeding location_tag_map data ..."
 
 CSV.foreach("#{Source_path}/openmrs_locationtagMapTbl.csv", :headers => true) do |row|

      
      LocationTagMap.create(location_id: row['location_id'], location_tag_id: row['location_tag_id'])
        
 end

puts ""
puts "location_tag_map seeded"

end

def startRetrieval
  
   seedLocation
   seedLocationTag
   seedLocationTagMap 
end

startRetrieval
