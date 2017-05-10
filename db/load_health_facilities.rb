puts "Loading health facilities"
CSV.foreach("#{Rails.root}/app/assets/data/health_facilities.csv", :headers => true) do |row|
    next if row[2].blank?
    district = District.find_by_name(row[0])
    health_facility = HealthFacility.create!(code: row[2],district_id: district.id,
                                            name: row[3],
                                            zone: row[4] , fac_type: row[5], 
                                            mga: row[6], f_type: row[7],
                                            latitude: row[8], longitude: row[9])
    puts "Loaded #{health_facility.name}"                                        
                                            
end
puts "Loaded health facilities !!!"