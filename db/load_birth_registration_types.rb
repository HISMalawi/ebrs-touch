puts "Loading Birth registration Types"
CSV.foreach("#{Rails.root}/app/assets/data/birth_registration_types.csv", :headers => false) do |row|
 next if row[0].blank?
 reg_type = BirthRegistrationType.create!(name: row[0].squish)
 puts "Loaded #{reg_type.name}"
end
puts "Loaded Birth Registration Types !!!"
