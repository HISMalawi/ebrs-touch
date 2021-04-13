cur_loc_id = SETTINGS['location_id']
cur_loc_name = Location.find(cur_loc_id).name
district_code = Location.find(cur_loc_id).code

year=Date.today.year

a = PersonBirthDetail.where("district_id_number LIKE '#{district_code}/%/#{year}' ").map(&:district_id_number)
a = a.collect{|bn| bn.split("/")[1].to_i}.sort

missing_bens = Array(a.first .. a.last) - a

missing_bens.each_with_index do |missing_ben, i|

	missing_person_id = ActiveRecord::Base.connection.select_one("SELECT person_id FROM ben_counter_#{year} WHERE counter = #{missing_ben.to_i};").as_json['person_id'] rescue nil

	next if missing_person_id.blank?

	PersonService.force_sync(missing_person_id) rescue nil

	d = PersonBirthDetail.where(person_id: missing_person_id).last
	d.generate_ben


	d = PersonBirthDetail.where(person_id: missing_person_id).last
	ben = d.district_id_number

	i = 1

	for i in 1..5
		d.save
	end


	puts "#{missing_person_id}  #{ben}"
end