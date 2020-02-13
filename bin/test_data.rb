def create
  	params = {}
  	params[:person] = {}
  	params[:person][:adoption_court_order]  = [nil,"Yes", "No"].sample
    params[:person][:informant][:designation] = nil
    params[:birth_place_details_available] = "Yes"
    params[:parents_details_available] = "Yes"
    params[:biological_parents] = "Yes"
    params[:foster_parents] = "No"

    params[:person][:first_name]  = Faker::Name.first_name
    params[:person][:last_name] = Faker::Name.last_name

    #raise params.inspect

    params[:person][:middle_name] = [Faker::Name.first_name,""].sample
    params[:birthdate] = Faker::Time.between("1964-01-01".to_time, Time.now()).to_date
    params[:person][:place_of_birth] = ["Home","Hospital","Other"].sample
    params[:person][:hospital_of_birth] = nil
    params[:person][:birth_district] = "Balaka"
    params[:person][:birth_weight] = "2.6"
    params[:person][:acknowledgement_of_receipt_date] = Date.today

    params[:person][:gender]  = ["Male","Female"].sample
    params[:person][:home_address_same_as_physical] = "Yes"
    params[:person][:same_address_with_mother] ="Yes"
    params[:person][:registration_type] = ["Normal","Abandoned","Adopted","Orphaned"].sample
    params[:person][:copy_mother_name]
    params[:person][:type_of_birth] = ["Single","First Twin", "Second Twin ", "First Triplet", "Second Triplet", "Third Triplet","Other"] 

    #raise birthdate.inspect

    ################################ mother details ###############################################

      params[:person][:mother] = {}
      params[:person][:mother][:last_name]  = Faker::Name.last_name
      params[:person][:mother][:first_name]  = Faker::Name.first_name
      params[:person][:mother][:middle_name] = [Faker::Name.first_name,""].sample
      params[:person][:mother][:birthdate] = Faker::Time.between("1964-01-01".to_time, (params[:birthdate].to_time - 15.years)).to_date
      params[:person][:mother][:citizenship] = "Malawian"
      params[:person][:mother][:residential_country] = "Malawi"
      params[:person][:mother][:foreigner_current_district] = nil
      params[:person][:mother][:foreigner_current_village] = nil
      params[:person][:mother][:foreigner_current_ta] = nil
      params[:person][:mother][:home_country] = "Malawi"
      params[:person][:mother][:foreigner_home_district] = nil
      params[:person][:mother][:foreigner_home_village] = nil
      params[:person][:mother][:foreigner_home_ta] = nil
      params[:person][:mother][:birthdate_estimated] = nil
      params[:person][:mother][:current_district] = "Balaka"
      params[:person][:mother][:current_ta] = "Balaka Boma"
      params[:person][:mother][:current_village] = "Mponda"

      params[:person][:mode_of_delivery] = ["SVD","Vacuum Extraction","Breech","Forceps","Caesarean Section"].sample
      params[:person][:level_of_education] = ["None","Secondary school", "College"].sample

    ################################ mother details (end) #######################################

    ########################### father details ########################################

 
      params[:informant_same_as_mother] = "No"
      

      params[:person][:father] = {}
      params[:person][:father][:birthdate_estimated] = 0
      params[:person][:father][:residential_country] = "Malawi"
      params[:person][:father][:foreigner_current_district] = nil
      params[:person][:father][:foreigner_current_village]  = nil
      params[:person][:father][:foreigner_current_ta] =  nil
      params[:person][:father][:residential_country] = nil
      params[:person][:father][:foreigner_home_village] = nil
      params[:person][:father][:foreigner_home_ta] = nil
      params[:person][:father][:last_name] = Faker::Name.last_name
      params[:person][:father][:first_name] = Faker::Name.first_name
      params[:person][:father][:middle_name] = [Faker::Name.first_name,""].sample
      params[:person][:father][:birthdate] =  Faker::Time.between("1964-01-01".to_time, (params[:birthdate].to_time - 15.years)).to_date
      params[:person][:father][:citizenship] = "Malawian"
      params[:person][:father][:current_district] = "Balaka"
      params[:person][:father][:current_ta] = "Balaka Boma"
      params[:person][:father][:current_village] = "Kaumphawi"
      params[:person][:father][:home_district] = "Balaka"
      params[:person][:father][:home_ta] = "Balaka Boma"
      params[:person][:father][:home_village] = "Mponda"

     

    ######################### father details (end) #################################

    params[:person][:informant] = {}
    params[:person][:informant][:last_name] = Faker::Name.last_name
    params[:person][:informant][:first_name] = Faker::Name.first_name
    params[:person][:informant][:middle_name] = [Faker::Name.first_name,""].sample
    params[:person][:informant][:relationship_to_child] = ["Uncle","Aunt","Grand mother"].sample
    params[:person][:informant][:current_district] = "Balaka"
    params[:person][:informant][:current_ta] = "Balaka Boma"
    params[:person][:informant][:current_village] = "Mponda"
    params[:person][:informant][:addressline1] 
    params[:person][:informant][:addressline2]
    params[:person][:informant][:phone_number] = ["+265883447123","+265884557664"].sample
    params[:person][:informant][:informant_same_as_father] = "No"

    params[:person][:form_signed] = nil



     #raise informant_current_ta.inspect

    params[:person][:court_order_attached] = nil
    params[:person][:parents_signed] = "Yes"

    params[:person][:parents_married_to_each_other] = 

    params[:month_prenatal_care_started] = "4"
    params[:number_of_prenatal_visits] = "4"
    params[:gestation_at_birth] = "8"
    params[:number_of_children_born_alive_inclusive] = 0
    params[:number_of_children_born_still_alive] = 0
    params[:details_of_father_known] = 0

    
end
create