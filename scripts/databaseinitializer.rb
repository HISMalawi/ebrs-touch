require 'csv'

Source_path = '/home/comish/Desktop/datamigration/'





def startRetrieval
  
 rows = {}
 location = []
 description = []

 CSV.foreach("/home/comish/Desktop/datamigration/openmrs_locationtbl.csv", :headers => true) do |row|

       rows = row[0]
       location = row[1]
       description = row[2]
  
   puts ">>>>>>>>>>>#{rows}>>>>>>>>>>>>>>>>>>>>>>>>>#{location}>>>>>>>>>>>>>>>>>>>#{description}"

 end


end

startRetrieval
