PersonBirthDetail.where("source_id LIKE '%-%' ").each do |pbd|

  source_id = pbd.source_id
  mass_person_id = -1 * source_id.split("#")[0].to_i
  mass_person = MassPerson.find(mass_person_id)
  mother      = PersonService.mother(pbd.person_id)
  father      = PersonService.father(pbd.person_id)

  if !mother.blank?
    mother_address     = PersonAddress.where(person_id: mother.person_id, citizenship: 35763).first
    if !mother_address.blank? 
     m_citizenship        = Location.where(country: mass_person.mother_nationality).last.id
     mother_address.citizenship = m_citizenship
     puts "M---#{pbd.person_id}  -- #{m_citizenship}"
     mother_address.residential_country = m_citizenship
     mother_address.save
    end 
  end

  if !father.blank?
    father_address     = PersonAddress.where(person_id: father.person_id, citizenship: 35763).first
   if !father_address.blank?
     f_citizenship        = Location.where(country: mass_person.father_nationality).last.id
     father_address.citizenship = f_citizenship
     puts "F---#{pbd.person_id} --- #{f_citizenship}"
     father_address.residential_country = f_citizenship
     father_address.save  
    end 
  end
end
