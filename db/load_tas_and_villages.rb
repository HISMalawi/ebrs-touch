puts "TA's and Villages'"
file = File.open("#{Rails.root}/app/assets/data/districts.json").read

village_json = JSON.parse(file)

village_json.each do |district, traditional_authorities|

    district = District.find_by_name(district)
	traditional_authorities.each do |traditional_authority, villages|
	 ta = TraditionalAuthority.create!(name: traditional_authority, district_id: district.id)
        puts "Loaded TA  #{ta.name} of #{district.name} district" 
		villages.each do |village|	
				vlg = Village.create!(name: village, traditional_authority_id: ta.id) 
                puts "Loaded  #{vlg.name} village of  TA  #{ta.name} of #{district.name} district" 
		end
	
	end

end

puts "Loaded TA's and Villages'"