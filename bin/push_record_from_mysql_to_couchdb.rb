def write_log(string)
    puts string
    File.open("#{Rails.root}/log/push_data_couch.txt", "a") { |f| f << string } 
end

#Find a way to optimize
#PersonBirthDetail.all.where("created_at BETWEEN '2010-01-01' AND '2018-12-31 23:59:59'")
person_count = 0
start_time = Time.now
Parallel.each_with_index(PersonBirthDetail.all,in_processes: 7)  do |detail,index|
    begin
        core_person = CorePerson.find(detail.person_id)
        core_person.save

        PersonName.where(person_id: detail.person_id).order(:created_at).each do |name|
            name.save
        end

        PersonIdentifier.where(person_id:  detail.person_id).order(:created_at).each do |id|
            id.save
        end


        PersonRelationship.where(person_a: detail.person_id).order(:created_at).each do |relationship|
            core_person = CorePerson.find(relationship.person_b)   
            core_person.save

            PersonName.where(person_id: relationship.person_b).order(:created_at).each do |name|
                name.save
            end
        
            PersonIdentifier.where(person_id:  relationship.person_b).order(:created_at).each do |id|
                id.save
            end        
            relationship.save
        end

        PersonRecordStatus.where(person_id: detail.person_id).order(:created_at).each do |status|
            status.save
        end
        detail.save
    rescue Exception => e
        write_log("\n#{detail.person_id} : #{e}")
    end
    if person_count < index
        person_count  = index
    end
    if person_count % 500 == 0
        puts "Pushed #{person_count} Record to couch"
    end
end

end_time = Time.now

puts "Pushed #{person_count} Record to couch"
puts "#{start_time} - #{end_time}"