#This script queries all community data and pushes to couchdb for syncing

def send_to_couch(person_id)
	#Core Person
	CorePerson.where(person_id: person_id).each{|a| a.save}	

	#Person
	Person.where(person_id: person_id).each{|a| a.save}	

	#Person
	PersonName.where(person_id: person_id).each{|a| a.save}	

	#PersonAttribute
	PersonAttribute.where(person_id: person_id).each{|a| a.save}	

	#PersonBirthDetail
	PersonBirthDetail.where(person_id: person_id).each{|a| a.save}	

	#PersonIdentifier
	PersonIdentifier.where(person_id: person_id).order(:created_at).each{|a| a.save}	

	#PersonRecordStatus
	PersonRecordStatus.where(person_id: person_id).order(:created_at).each{|a| a.save}	

	#PersonRelationship
	PersonRelationship.where(person_a: person_id).order(:created_at).each{|a| 

		send_to_couch(a.person_b)
		a.save		
	}	
end

person_ids = PersonBirthDetail.where(" source_id LIKE '%#%' ").map(&:person_id)
person_ids.each_with_index do |pid, i|
	puts "#{(i + 1)} # pid: #{pid}"
	send_to_couch(pid)
end

