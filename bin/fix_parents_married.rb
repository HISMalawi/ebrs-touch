PersonBirthDetail.where("source_id LIKE '%-%' ").each.with_index do |pbd, i|
 puts i
 next if i < 80000
  source_id = pbd.source_id
  mass_person_id = -1 * source_id.split("#")[0].to_i
  mass_person = MassPerson.find(mass_person_id)
  
  if mass_person.parents_married == "Yes"
	pbd.parents_married_to_each_other = 1
	pbd.save
  else
	pbd.parents_married_to_each_other = 0
	pbd.save
  end
end
