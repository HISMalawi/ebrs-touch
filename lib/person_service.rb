module PersonService
	require 'bean'
	require 'json'

  def self.create_record(params)
    first_name 			= 		params[:person]["first_name"]
    last_name 			= 		params[:person]["last_name"]
    middle_name 		= 		params[:person]["middle_name"]
    place_of_birth		= 		params[:person]["place_of_birth"]
    hospital_of_birth	=		params[:person]["hospital_of_birth"]
    birth_district		=		params[:person]["birth_district"]
    birth_weight		= 		params[:person]["birth_weight"]
    acknowledgement_of_receipt_date	= params[:person]["acknowledgement_of_receipt_date"]

    gender 				      	  =  params[:child]["gender"]
    home_address_same_as_physical =  params[:child]["home_address_same_as_physical"]
    details_of_father_known 	  =  params[:child]["details_of_father_known"]
    same_address_with_mother	  =  params[:child]["same_address_with_mother"]
    registration_type 	  = params[:child]["registration_type"]
    copy_mother_name    = params[:child]["copy_mother_name"]
    type_of_birth		=		params[:child]["type_of_birth"]
    mother_last_name 	=		params[:child][:mother]["last_name"]
    mother_first_name	=		params[:child][:mother]["first_name"]
    mother_middle_name	=		params[:child][:mother]["middle_name"]
    mother_birthdate	=		params[:child][:mother]["birthdate"]
    mother_citizenship	=		params[:child][:mother]["citizenship"]
    mother_residental_country = params[:child][:mother]["residential_country"]
    mother_foreigner_current_district = param[:child][:mother]["foreigner_current_district"]
    mother_foreigner_current_village = params[:child][:mother]["foreigner_current_village"]
    mother_foreigner_current_ta =  params[:child][:mother]["foreigner_current_ta"]
    mother_home_country    = params[:child][:mother]["home_country"]
    mother_foreigner_home_district = params[:child][:mother]["foreigner_home_district"]
    mother_foreigner_home_village  = params[:child][:mother]["foreigner_home_village"]
    mother_foreigner_home_ta = params[:child][:mother]["foreigner_home_ta"]
    mother_mode_of_delivery =   parms[:child][:mother["mode_of_delivery"]
    mother_level_of_education = params[:child][mother]["level_of_education"]

    father_birthdate_estimated = params[:child][:father]["birthdate_estimated"]
    father_residential_country = params[:child][:father]["residential_country"]

    informant_last_name = params[:child][:informant]["last_name"]
    informant_first_name = params[:child][:informant]["first_name"]
    informant_middle_name = params[:child][:informant]["middle_name"]
    informant_relationship_to_child = params[:child][:informant]["relationship_to_child"]
    informant_current_district = params[:child][:informant]["current_district"]
    informant_current_ta  = params[:child][:informant]["current_ta"]
    informant_current_village = params[:child][:informant]["current_village"]
    informant_addressline1  = params[:child][:informant]["addressline1"]
    informant_addressline2 = params[:child][:informant]["addressline2"]
    informant_phone_number = params[:child][:informant]["phone_number"]
    informant_form_signed = params[:child][:informant]["form_signed"]
    informant_same_as_mother = params[:child][:informant]["informant_same_as_mother"]




    mother_estimated_dob	=	params[:child][:mother]["birthdate_estimated"]
    court_order_attached	=		params[:child]["court_order_attached"]

    parents_married_to_each_other	=	params[:child]["parents_married_to_each_other"]

   
  end

end
