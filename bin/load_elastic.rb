details = PersonBirthDetail.all
total = details.count
m_type = PersonRelationType.find_by_name("Mother")
f_type = PersonRelationType.find_by_name("Father")

Parallel.each_with_index(details,in_processes: 7)  do |d,i|
  @name = PersonName.where(person_id: d.person_id).last
  @person = Person.find(d.person_id)

  m_rel = PersonRelationship.where(:person_a => d.person_id, :person_relationship_type_id => m_type.id).last

  next if m_rel.blank?

  @mother_person = Person.find(m_rel.person_b)
  @mother_name = PersonName.where(person_id: m_rel.person_b).last
  @mother_address = @mother_person.addresses.last rescue nil

  f_rel = PersonRelationship.where(:person_a => d.person_id, :person_relationship_type_id => f_type.id).last
  @father_person = Person.find(f_rel.person_b) rescue nil
  @father_name = PersonName.where(person_id: f_rel.person_b).last rescue nil
  @father_address = @father_person.addresses.last rescue nil

  person = {}
  person["id"] = @person.person_id.to_s
  person["first_name"]= @name.first_name rescue ''
  person["last_name"] =  @name.last_name rescue ''
  person["middle_name"] = @name.middle_name rescue ''
  person["gender"] = (@person.gender == 'F' ? 'Female' : 'Male')
  person["birthdate"]= @person.birthdate.to_date
  person["birthdate_estimated"] = @person.birthdate_estimated
  person["nationality"]=  @mother_person.citizenship rescue ''
  person["place_of_birth"] = Location.find(d.birth_location_id).name rescue nil
  person["district"] = Location.find(d.district_of_birth).name

  person["mother_first_name"]= @mother_name.first_name rescue ''
  person["mother_last_name"] =  @mother_name.last_name  rescue ''
  person["mother_middle_name"] = @mother_name.middle_name rescue ''

  person["mother_home_district"] = Location.find(@mother_address.home_district).name rescue nil
  person["mother_home_ta"] = Location.find(@mother_address.home_ta).name rescue nil
  person["mother_home_village"] = Location.find(@mother_address.home_village).name rescue nil

  person["mother_current_district"] = Location.find(@mother_address.current_district).name rescue nil
  person["mother_current_ta"] = Location.find(@mother_address.current_ta).name rescue nil
  person["mother_current_village"] = Location.find(@mother_address.current_village).name rescue nil

  person["father_first_name"]= @father_name.first_name  rescue ''
  person["father_last_name"] =  @father_name.last_name  rescue ''
  person["father_middle_name"] = @father_name.middle_name  rescue ''

  person["father_home_district"] = Location.find(@father_address.home_district).name rescue nil
  person["father_home_ta"] = Location.find(@father_address.home_ta).name rescue nil
  person["father_home_village"] = Location.find(@father_address.home_village).name rescue nil

  person["father_current_district"] = Location.find(@father_address.current_district).name rescue nil
  person["father_current_ta"] = Location.find(@father_address.current_ta).name rescue nil
  person["father_current_village"] = Location.find(@father_address.current_village).name rescue nil

  SimpleElasticSearch.add(person) rescue next

  if i % 100 == 0
    puts "#{i} / #{total}"
  end
end
