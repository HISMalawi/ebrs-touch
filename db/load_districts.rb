
puts "Loading Districts"
CSV.foreach("#{Rails.root}/app/assets/data/districts_with_codes.csv", :headers => true) do |row|
 next if row[0].blank?
 country = Country.find_by_name("Malawi")
 district = District.create!(country_id: country.id, code: row[0], name: row[1], region: row[2])
 puts "Loaded #{district.name}"
end
puts "Loaded Districts of Malawi !!!"