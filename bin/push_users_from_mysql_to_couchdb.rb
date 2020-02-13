 user_count = 0
 Parallel.each_with_index(User.all.order(:created_at),in_processes: 12) do |user,index|
         core_person = CorePerson.find(user.person_id)
         core_person.save
         PersonName.where(person_id: user.person_id).order(:created_at).each do |name|
             name.save
         end
         user.save
         user_count  = index + 1
         if user_count % 100 == 0
             puts "Pushed #{user_count} users to couch"
         end
end


puts "Done pushing #{user_count} users to couch"

GC.start
exit
sleep(15)
exit
