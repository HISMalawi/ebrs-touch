all = PersonBirthDetail.where(" source_id LIKE '%#%' ")
district_loc = Location.where(name: "Ntcheu").first
tag_id = LocationTag.where(name: "Traditional Authority").first.id
nu_tas       = Location.find_by_sql(" SELECT * FROM location l
                  INNER JOIN location_tag_map m ON l.location_id = m.location_id
                  WHERE l.parent_location = #{district_loc.id} AND
                  m.location_tag_id = #{tag_id} ").collect{|l| l.id}

all.each do |pbd|
   source_id = pbd.source_id.split("#")[0].to_i * -1
   loc = Location.find(pbd.location_created_at) rescue (puts "#{pbd.location_created_at}")
   next if loc.blank? 

   if nu_tas.include?(loc.parent_location)
      next
   end 
  
 
  true_loc = Location.where(" name = '#{loc.name}' AND parent_location IN (#{nu_tas.join(',')} ) ")
  puts "#{loc.name}: #{true_loc.count}"  

  if true_loc.length == 1
	puts "#One village: {pbd.person_id}"
	pbd.location_created_at = true_loc.first.id
	#pbd.save
  elsif true_loc.length > 1
	record = MassPerson.find(source_id)
	ta_name = record.ta_created_at
	ta_id = Location.where("  name = '#{ta_name}' AND parent_location = #{district_loc.id}   ").first.id
	village_id = true_loc.collect{|l| l.id if ta_id == l.parent_location}.compact.first
	pbd.location_created_at =  village_id
        puts "More villages: #{village_id}"
 	#pbd.save
  end 

end
