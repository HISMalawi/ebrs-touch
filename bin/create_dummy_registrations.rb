require 'rubygems'
require 'faker'

current_date = DateTime.now.strftime("%d/%m/%Y %H:%M")

puts current_date
start = 0
count = 10

params = []

gender = %w[Male,Female]

my_date_list = []

1.upto(14).each do |n| 
    my_date_list << (Date.today - n.day).strftime('%d/%b/%Y')
    puts "<<<<<<<<<<<<<<<<<<<<<< #{my_date_list[n]} <<<<<<<<<<<<<<<<"
end
=begin

while start < count do

	element = rand(gender.length)


	params << {"person"=>{"duplicate"=>"",
		 "is_exact_duplicate"=>"",
		 "relationship"=>"normal",
		 "last_name"=> Faker::Name.last_name,
		 "first_name"=> Faker::Name.first_name,
		 "middle_name"=>"",
		 "birthdate"=> current_date,
		 "birth_district"=>"Blantyre City",
		 "gender"=> gender[element],
		 "place_of_birth"=>"Hospital",
		 "hospital_of_birth"=>"Amitofo Care Centre",
		 "birth_weight"=>"3.000",
		 "type_of_birth"=>"Single",
		 "parents_married_to_each_other"=>"No",
		 "court_order_attached"=>"Yes",
		 "mother" => {"last_name"=> Faker::Name.last_name,
		 "first_name"=> Faker::Name.first_name,
		 "middle_name"=> "",
		 "birthdate"=> Faker::Date.backward(20.years.ago),
		 "birthdate_estimated"=>"",
		 "citizenship"=> Faker::Address.country,
		 "residential_country"=> Faker::Address.country,
		 "current_district"=>"Blantyre",
		 "current_ta"=>"Kuntaja",
		 "current_village"=>"Bakili",
		 "home_district"=>"Blantyre",
		 "home_ta"=>"Kuntaja",
		 "home_village"=>"Bakili"},
		 "mode_of_delivery"=>"Vacuum Extraction",
		 "level_of_education"=>"Secondary",
		 "father"=>{"last_name"=> Faker::Name.last_name,
		 "first_name"=> Faker::Name.first_name,
		  "middle_name"=> "",
		  "birthdate"=> Faker::Date.backward(28.years.ago),
		 "birthdate_estimated"=>"",
		  "citizenship"=> Faker::Address.country,
		 "residential_country"=>Faker::Address.country,
		 "current_district"=>"Blantyre",
		 "current_ta"=>"Kuntaja",
		 "current_village"=>"Bakili",
		 "home_district"=>"Blantyre",
		 "home_ta"=>"Kapeni",
		 "home_village"=>"Beni Ligogo"},
		 "informant"=>{"last_name"=> Faker::Name.last_name,
		 "first_name"=>Faker::Name.first_name,
		 "middle_name"=>"",
		 "relationship_to_person"=>"Mother",
		 "current_district"=>"Blantyre",
		 "current_ta"=>"Kuntaja",
		 "current_village"=>"Bakili",
		 "addressline1"=>"",
		 "addressline2"=>"",
		 "phone_number"=>""},
		 "form_signed"=>"Yes",
		 "acknowledgement_of_receipt_date"=>"16/Aug/2017"},
		 "home_address_same_as_physical"=>"No",
		 "gestation_at_birth"=>"36",
		  "number_of_prenatal_visits"=>"6",
		 "month_prenatal_care_started"=>"6",
		 "number_of_children_born_alive_inclusive"=>"1",
		 "number_of_children_born_still_alive"=>"1",
		 "details_of_father_known"=>"Yes",
		 "same_address_with_mother"=>"Yes",
		 "informant_same_as_mother"=>"Yes",
		 "registration_type"=>"No"}

	person = PersonService.create_record(params)

end

=end
