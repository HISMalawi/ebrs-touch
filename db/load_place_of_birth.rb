
puts "Loading Place Of Birth"

location_tag = LocationTag.where(name: 'Place Of Birth').first

CSV.foreach("#{Rails.root}/app/assets/data/place_of_birth.csv", :headers => false) do |row|
 next if row[0].blank?
 place_of_birth = Location.create!(name: row[0])
 LocationTagMap.create(location_id: place_of_birth.id, location_tag_id: location_tag.id)
 puts "Loaded #{place_of_birth.name}"

end
puts "Loaded Place of Birth !!!"
