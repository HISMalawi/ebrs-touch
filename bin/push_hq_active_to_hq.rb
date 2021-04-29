cur_loc_id = SETTINGS['location_id']
cur_loc_name = Location.find(cur_loc_id).name
district_code = Location.find(cur_loc_id).code

def write_csv_header(file, header)
    CSV.open(file, 'w' ) do |exporter|
        exporter << header
    end
end

def write_csv_content(file, content)
    CSV.open(file, 'a+' ) do |exporter|
        exporter << content
    end
end

header = [  "Person ID"
		]
write_csv_header("#{Rails.root}/db/#{district_code}_hq_active.csv", header)

person_ids = PersonRecordStatus.find_by_sql("
	 SELECT distinct d.person_id FROM person_birth_details d
	INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
	WHERE prs.status_id = 8 AND prs.voided = 0 AND d.district_id_number like '#{district_code}/%'
	 ").map(&:person_id).uniq

person_ids.each_with_index do |person_id, i|

	prs = PersonRecordStatus.where(person_id: person_id, status_id: 8, voided: 0).last
	i = 1
	for i in 1..20 do
		prs.save
	end

	row = [ person_id
	]


	write_csv_content("#{Rails.root}/db/#{district_code}_hq_active.csv", row)

	puts "#{i}:  #{person_id} done"
end