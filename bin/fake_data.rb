User.current = User.last


def start
  puts "Please enter number of names to generate: "
  x = gets.chomp

  1.upto(x.to_i).each do |n|
    params = setup_data
    ActiveRecord::Base.transaction do
      #puts ">>>>>>>>>>>>>>>> #{params[:person][:type_of_birth]}"
      person = PersonService.create_record(params)
      if person.present? 
        #SimpleElasticSearch.add(person_for_elastic_search(params))
        #IdentifierAllocationQueue.create(person_id: person.person_id, person_identifier_type_id: 2)
        record_status = PersonRecordStatus.where(person_id: person.person_id).first
        record_status.update_attributes(status_id: Status.where(name: 'DC-ACTIVE').last.id)
        puts "Created ............. #{n}"
      end
    end
  end
end 
 
 
def setup_data
    my_date_list = []

  1.upto(14).each do |n| 
    my_date_list << (Date.today - n.day).strftime('%d/%b/%Y')
  end

  gender = ['Male','Female']
  level_of_education = ["Higher Education","Secondary Education","Primary Education","None"]
  number_of_prenatal_visits = [1,2,3,4,5,6]

  kgs = Random.rand(2..6).to_s.ljust(4,'0')
  kgs = "#{kgs[0..0]}.#{kgs[1..-1]}" 

  t1 = (Date.today - 12.day)
  t2 = Date.today
  birthdate1 = rand(t1..t2)

  t1 = (Date.today - 50.year)
  t2 = (Date.today - 20.year)
  birthdate2 = rand(t1..t2)

  t1 = (Date.today - 9.month)
  t2 = Date.today
  date_of_reporting = rand(t1..t2)


  mother_first_name = Faker::Name.first_name
  mother_last_name = Faker::Name.last_name

   data = { person: {duplicate: "", is_exact_duplicate: "", 
   relationship: "Adopted", 
   last_name: Faker::Name.last_name, 
   first_name: Faker::Name.first_name, 
   middle_name: "", 
   birthdate: birthdate1.strftime('%d/%b/%Y'), 
   birth_district: "Lilongwe City", 
   gender: gender[rand(0..1)], 
   place_of_birth: "Hospital", 
   hospital_of_birth: "ABC Comm. Hospital", 
   birth_weight: kgs, 
   type_of_birth: "Single", 
   parents_married_to_each_other: "No", 
   court_order_attached: "No", 
   parents_signed: "No", 
   mother:{
     last_name: Faker::Name.last_name, 
     first_name: Faker::Name.first_name, 
     middle_name: "", 
     birthdate: birthdate1.strftime('%d/%b/%Y'), 
     birthdate_estimated: "", 
     citizenship: "Malawian", 
     residential_country: "Malawi", 
     current_district: "Balaka", 
     current_ta: "Amidu", 
     current_village: "Bakili", 
     home_district: "Balaka", 
     home_ta: "Amidu", 
     home_village: "Bakili"
  }, 
   mode_of_delivery: "SVD", 
   level_of_education: level_of_education[rand(level_of_education.length)], 
   father: {
     birthdate_estimated: "", 
     residential_country: ""
  }, 
   informant: {
     last_name: mother_last_name, 
     first_name: mother_first_name, 
     middle_name: "", 
     relationship_to_person: "Mother", 
     current_district: "Balaka", 
     current_ta: "Amidu", 
     current_village: "Bakili", 
     addressline1: "", 
     addressline2: "", 
     phone_number: ""
  }, 
   form_signed: "Yes", 
   acknowledgement_of_receipt_date: my_date_list[rand(my_date_list.length)]
  }, 
   home_address_same_as_physical: "Yes", 
   gestation_at_birth: "39", 
   number_of_prenatal_visits: number_of_prenatal_visits[rand(number_of_prenatal_visits.length)].to_s, 
   month_prenatal_care_started: number_of_prenatal_visits[rand(number_of_prenatal_visits.length)].to_s, 
   number_of_children_born_alive_inclusive: "1", 
   number_of_children_born_still_alive: "1", 
   same_address_with_mother: "", 
   informant_same_as_mother: "Yes", 
   registration_type: "No", 
   copy_mother_name: "No", 
   controller: "person", 
   action: "create",
   date_reported: Date.today.to_s
  }

  return data
end


start
