require 'csv'

Source_path = '/home/comish/Desktop/datamigration/'





def startRetrieval
 datarow =[]
 rows = {}
 location = []
 description = []

 CSV.foreach("/home/comish/Desktop/datamigration/openmrs_locationtbl.csv", :headers => true) do |row|

       rows = row[0]
       location = row[1]
       description = row[2]
       datarow = [[row[0]],[row[1]],[row[2]]]
    
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>..#{datarow}"  
 end

  
end

startRetrieval
