all = PersonBirthDetail.where(" source_id LIKE '%#%' AND person_id = 83291 ")
district_loc = Location.where(name: "Ntcheu").first
tag_id = LocationTag.where(name: "Traditional Authority").first.id
nu_tas       = Location.find_by_sql(" SELECT * FROM location l
                  INNER JOIN location_tag_map m ON l.location_id = m.location_id
                  WHERE l.parent_location = #{district_loc.id} AND
                  m.location_tag_id = #{tag_id} ").collect{|l| l.id}
all.each_with_index do |pbd, i|
   puts i
   source_id = pbd.source_id.split("#")[0].to_i * -1
   
    record = MassPerson.find(source_id)
    ta_name = record.ta_created_at
    ta_id = Location.where("  name = \"#{ta_name}\" AND parent_location = #{district_loc.id}   ").first.id
    village_id = Location.locate_id(record.location_created_at, "Village", ta_id)
    pbd.location_created_at =  village_id
    puts "#{pbd.person_id} #Location ID: #{village_id}"
    pbd.save
end
