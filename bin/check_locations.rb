#This script checks for wrong location filled in locations_created_at
#of person_birth_details for Community Data

records = PersonBirthDetail.where(" source_id LIKE '-%#%' ")
puts "Total Of #{records.count} records found"
file_name = "person_locations.csv"

File.open(file_name, "w"){|f|
	f.write("person_id|location_created_at\n")
}

district  = ARGV[0]
code      = ARGV[1]

district_id = Location.where(name: district, code: code).first.id
locations_map = Location.where(parent_location: district_id).inject({}){|h, l| h[l.name] = l.id; h}
location_ids  = locations_map.values

k = 0
records.each_with_index do |detail, i|
		mass_person_id = detail.source_id.split("#")[0].to_i * -1
		mass_person = MassPerson.find(mass_person_id)		

		ta_id 	= locations_map[mass_person.ta_created_at]
		village_id = Location.where(name: mass_person.location_created_at, parent_location: ta_id).last.id		
		puts "#{detail.location_created_at} -> #{village_id}"

		if detail.location_created_at != village_id 		
			k += 1
			puts "#{i} ##  #{detail.location_created_at} ## #{village_id} ## #{k}"
			detail.location_created_at = village_id
			detail.save
		end
end
