district_code = "KA"

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

header = [  "Person ID",
			"Birth Entry Number",
			"National ID / BRN", 
			"Name",
			"Date of Birth",
			"Sex",
			"Place of Birth",
			"Name of Mother",
			"Nationality of Mother",
			"Name of Father",
			"Nationality of Father",
			"Date of Registration",
			"QR Code",
			"District",
			"TA",
			"Village",
			"Postal Address",
			"Phone Number",
			"Owner of the Addresses"
		]
write_csv_header("#{Rails.root}/db/#{district_code}_print_file.csv", header)

person_ids = PersonRecordStatus.find_by_sql("
	 SELECT distinct d.person_id FROM person_birth_details d
	INNER JOIN person_record_statuses prs ON d.person_id = prs.person_id
	WHERE prs.status_id IN(44,27,36,37,51,52) AND prs.voided = 0 AND d.district_id_number like '#{district_code}/%'
	 ").map(&:person_id).uniq

puts person_ids.count

person_ids.each_with_index do |person_id, i|
	puts "#{person_id}"
	
	pbd 			= PersonBirthDetail.where(person_id: person_id).last

	ben 			= pbd.district_id_number

	registration_number	=	nil

	nid_identifier 	= PersonIdentifier.where(person_id: person_id, person_identifier_type_id: 4, voided: 0).last
	national_id 	= nil
	if !nid_identifier.blank?
		national_id 	= nid_identifier.value
	end

	brn 			= pbd.brn rescue nil

	if brn.blank?
		pbd.generate_brn

		d = PersonBirthDetail.where(person_id: person_id).last
		brn = d.brn
	end

	person = Person.find(person_id)

	full_name = person.printable_name rescue nil

	if full_name.blank?
		#PersonService.force_sync(person_id)
		#full_name = person.printable_name rescue nil
		next if full_name.blank?
	end

	birthdate = person.birthdate.to_date.strftime("%d-%b-%Y")
	gender		=	person.gender
	birth_day	=	person.birthdate.to_date.strftime("%d").to_i
	sup 		= 	person.birthdate.to_date.strftime("%d").to_i.ordinalize.gsub(/\d+/, "")
	birth_month	=	person.birthdate.to_date.strftime("%B")
	birth_year	=	person.birthdate.to_date.strftime("%Y")

	mother_name 		=	person.mother.printable_name rescue nil
	if mother_name.blank?
		#PersonService.force_sync(person_id)
		#mother_name 		=	person.mother.printable_name rescue nil
	end

	mother_nationality 	=	person.mother.citizenship rescue nil
	if mother_nationality.blank?
		#PersonService.force_sync(person_id)
		#mother_nationality 	=	person.mother.citizenship rescue nil
	end

	father_name 		=	person.father.printable_name rescue nil
	if father_name.blank?
		#PersonService.force_sync(person_id)
		#father_name 		=	person.father.printable_name rescue nil
	end

	father_nationality 	=	person.father.citizenship rescue nil
	if father_nationality.blank?
		#PersonService.force_sync(person_id)
		#father_nationality 	=	person.father.citizenship rescue nil
	end

	prs 		= PersonRecordStatus.where(person_id: person_id, status_id: 8).last

	date_registered 	=	pbd.date_registered rescue nil

	if date_registered.present?
		next if date_registered.to_date > "2021-03-31".to_date
	else
		approved = prs.created_at rescue nil
		if approved.present?
			next if approved.to_date > "2021-03-31".to_date
		end
	end

	day_of_registration 	= nil
	date_registered_sup 	= nil
	month_of_registration 	= nil
	year_of_registration 	= nil

	if !date_registered.blank?
		day_of_registration		= 	pbd.date_registered.to_date.strftime("%d").to_i
		date_registered_sup		=	pbd.date_registered.to_date.strftime("%d").to_i.ordinalize.gsub(/\d+/, "")
		month_of_registration 	=	pbd.date_registered.to_date.strftime("%B")
		year_of_registration	=	pbd.date_registered.to_date.strftime("%Y")
	
	elsif !prs.blank?
		day_of_registration		= 	prs.created_at.to_date.strftime("%d").to_i
		date_registered_sup		=	prs.created_at.to_date.strftime("%d").to_i.ordinalize.gsub(/\d+/, "")
		month_of_registration 	=	prs.created_at.to_date.strftime("%B")
		year_of_registration	=	prs.created_at.to_date.strftime("%Y")
	end

	date_of_registration 		=	"#{day_of_registration}#{date_registered_sup} #{month_of_registration}, #{year_of_registration}"


	birth_district = Location.find(pbd.district_of_birth).name rescue nil
	place_of_birth = Location.find(pbd.birth_location_id).name rescue pbd.other_place_of_birth

	if place_of_birth.downcase == 'other'
      place_of_birth = pbd.other_birth_location
    end
    if !place_of_birth.blank?
      place_of_birth += ", " + birth_district
    else
      place_of_birth = birth_district
    end

    qr_code = PersonService.qr_code_data(person_id)

    district 	= nil
    ta 			= nil
    village 	= nil
    address1 	= nil
    address2 	= nil
    phone_number	= nil

    address_owner	= nil



    informant_person 	= person.informant rescue nil
    informant_address 	= informant_person.addresses.last rescue nil
    mother_address		= person.mother.addresses.last rescue nil
    father_address 		= person.father.addresses rescue nil

    #raise Location.find(mother_address.current_district).name.inspect

    informant_current_district 			= Location.find(informant_address.current_district).name rescue nil
	informant_current_ta 				= Location.find(informant_address.current_ta).name rescue nil
	informant_current_village 			= Location.find(informant_address.current_village).name rescue nil

	informant_home_district				= Location.find(informant_address.home_district).name rescue nil
	informant_home_ta					= Location.find(informant_address.home_ta).name rescue nil
	informant_home_village				= Location.find(informant_address.home_village).name rescue nil

	informant_current_district_other	= informant_address.current_district_other rescue nil
	informant_current_ta_other			= informant_address.current_ta_other rescue nil
	informant_current_village_other		= informant_address.current_village_other rescue nil

	informant_home_district_other		= informant_address.home_district_other rescue nil
	informant_home_ta_other				= informant_address.home_ta_other rescue nil
	informant_home_village_other		= informant_address.home_village_other rescue nil


	mother_current_district 			= Location.find(mother_address.current_district).name rescue nil
	mother_current_ta 					= Location.find(mother_address.current_ta).name rescue nil
	mother_current_village 				= Location.find(mother_address.current_village).name rescue nil

	mother_home_district				= Location.find(mother_address.home_district).name rescue nil
	mother_home_ta 						= Location.find(mother_address.home_ta).name rescue nil
	mother_home_village					= Location.find(mother_address.home_village).name rescue nil

	mother_current_district_other		= mother_address.current_district_other rescue nil
	mother_current_ta_other				= mother_address.current_ta_other rescue nil
	mother_current_village_other		= mother_address.current_village_other rescue nil

	mother_home_district_other			= mother_address.home_district_other rescue nil
	mother_home_ta_other				= mother_address.home_ta_other rescue nil
	mother_home_village_other			= mother_address.home_village_other rescue nil

	    
	father_current_district 			= Location.find(father_address.current_district).name rescue nil
	father_current_ta 					= Location.find(father_address.current_ta).name rescue nil
	father_current_village 				= Location.find(father_address.current_village).name rescue nil

	father_home_district				= Location.find(father_address.home_district).name rescue nil
	father_home_ta 						= Location.find(father_address.home_ta).name rescue nil
	father_home_village					= Location.find(father_address.home_village).name rescue nil

	father_current_district_other		= father_address.current_district_other rescue nil
	father_current_ta_other				= father_address.current_ta_other rescue nil
	father_current_village_other		= father_address.current_village_other rescue nil

	father_home_district_other			= father_address.home_district_other rescue nil
	father_home_ta_other				= father_address.home_ta_other rescue nil
	father_home_village_other			= father_address.home_village_other rescue nil
	    
	address1 			= Location.find(informant_address.address_line_1).name rescue nil
	address2 			= Location.find(informant_address.address_line_2).name rescue nil

	informant_address_id = informant_address.person_id rescue nil

	if informant_address_id.present?
		phone_attrib = PersonAttribute.where(person_id: informant_address_id, person_attribute_type_id: 4).last
		phone_number = phone_attrib.value rescue nil
	end

    postal_address 			= "#{address1}  #{address2}"


    if informant_current_district.present?
    	district 	= informant_current_district
    	ta 			= informant_current_ta
    	village 	= informant_current_village

    	if district == "Other"
    		district 	= informant_current_district_other
    	end

    	if ta == "Other"
    		ta = informant_current_ta_other
    	end

    	if village == "Other"
    		village 	= informant_current_village_other
    	end

    	address_owner = "Informant Physical Residential Address"

    elsif informant_home_district.present?
    	district 	= informant_home_district
    	ta 			= informant_home_ta
    	village 	= informant_home_village

    	if district == "Other"
    		district = informant_home_district_other
    	end

    	if ta == "Other"
    		ta = informant_home_ta_other
    	end

    	if village == "Other"
    		village = informant_home_village_other
    	end

    	address_owner = "Informant Home Address"

    elsif mother_current_district.present?
    	district 	= mother_current_district
    	ta 			= mother_current_ta
    	village 	= mother_current_village

    	if district == "Other"
    		district = mother_current_district_other
    	end
    	if ta == "Other"
    		ta = mother_current_ta_other
    	end
    	if village == "Other"
    		village = mother_current_village_other
    	end

    	address_owner = "Mother Physical Residential Address"

    elsif mother_home_district.present?
    	district 	= mother_home_district
    	ta 			= mother_home_ta
    	village 	= mother_home_village

    	if district == "Other"
    		district = mother_home_district_other
    	end
    	if ta == "Other"
    		ta = mother_home_ta_other
    	end
    	if village == "Other"
    		village = mother_home_village_other
    	end
    	
    	address_owner = "Mother Home Address"

    elsif father_current_district.present?
    	district 	= father_current_district
    	ta 			= father_current_ta
    	village 	= father_current_village

    	if district == "Other"
    		district = father_current_district_other
    	end
    	if ta == "Other"
    		ta = father_current_ta_other
    	end
    	if village == "Other"
    		village = father_current_village_other
    	end

    	address_owner = "Father Physical Residential Addresses"

    elsif father_home_district.present?
    	district 	= father_home_district
    	ta 			= father_home_ta
    	village 	= father_home_village

    	if district == "Other"
    		district = father_home_district_other
    	end
    	if ta == "Other"
    		ta = father_home_ta_other
    	end
    	if village == "Other"
    		village = father_home_village_other
    	end

    	address_owner = "Father Home Addresses"

    elsif informant_current_district_other.present?
    	district 	= informant_current_district_other
    	ta 			= informant_current_ta_other
    	village 	= informant_current_village_other

    	address_owner = "Informant Other Addresses"

    elsif informant_home_district_other.present?
    	district 	= informant_home_district_other
    	ta 			= informant_home_ta_other
    	village 	= informant_home_village_other

    	address_owner = "Informant Other Addresses"

    elsif mother_current_district_other.present?
    	district 	= mother_current_district_other
    	ta 			= mother_current_ta_other
    	village 	= mother_current_village_other

    	address_owner = "Mother Other Physical Residential Addresses"

    elsif mother_home_district_other.present?
    	district 	= mother_home_district_other
    	ta 			= mother_home_ta_other
    	village 	= mother_home_village_other

    	address_owner = "Mother Other Home Addresses"

    elsif father_current_district_other.present?
    	district 	= father_current_district_other
    	ta 			= father_current_ta_other
    	village 	= father_current_village

    	address_owner = "Father Other Physical Residential Addresses"

    elsif father_home_district_other.present?
    	district 	= father_home_district_other
    	ta 			= father_home_ta_other
    	village 	= father_home_village

    	address_owner = "Father Other Home Addresses"
   
    end


    if national_id.present?
    	registration_number = national_id
    else
    	registration_number = "file_" + brn
    end


	row = [ person_id,
			ben,
			registration_number,
			full_name,
			"#{birth_day}#{sup} #{birth_month}, #{birth_year}",
			gender == "M" ? "Male" : "Female",
			place_of_birth,
			mother_name,
			mother_nationality,
			father_name,
			father_nationality,
			date_of_registration,
			qr_code,
			district,
			ta,
			village,
			postal_address,
			phone_number,
			address_owner

	]


	write_csv_content("#{Rails.root}/db/#{district_code}_print_file.csv", row)

	puts "#{person_id} success"
end
