PersonBirthDetail.where("source_id LIKE '%-%' ").each.with_index do |pbd, i|
 #puts i
 #next if i < 80000

  informant = PersonRelationship.where(person_a: pbd.person_id, person_relationship_type_id: 4).first

  address = PersonAddress.where(person_id: informant.person_b).last

  if address.current_ta == 33576

    source_id = pbd.source_id
    mass_person_id = -1 * source_id.split("#")[0].to_i
    mass_person = MassPerson.find(mass_person_id)
    
    if mass_person.parents_married == "Yes"
      pbd.parents_married_to_each_other = 1
      pbd.save
      puts "#{pbd.person_id} married"
    else
      pbd.parents_married_to_each_other = 0
      pbd.save
      puts "#{pbd.person_id} not married"
    end

  end

end
