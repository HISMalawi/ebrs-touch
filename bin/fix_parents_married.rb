PersonBirthDetail.where("source_id LIKE '%-%' ").each.with_index do |pbd, i|
 puts i

  source_id = pbd.source_id
  mass_person_id = -1 * source_id.split("#")[0].to_i
  mass_person = MassPerson.find(mass_person_id)
  
  if mass_person.parents_married
	pbd.parents_married_to_each_other = 1
	pbd.save
  end
end
