puts Pusher

all = PersonBirthDetail.where(" DATE(created_at) BETWEEN '2019-05-25' AND '#{Date.today.to_s}' ")

total = 0
person_ids = []
all.each do |pbd|
  suspected = false
  total_pid = PersonBirthDetail.where(person_id: pbd.person_id)
  if total_pid.count > 1
    suspected = true
  end

  rels = PersonRelationship.where(person_a: pbd.person_id)
  if rels.length > 4
    suspected = true
  end

  if suspected
    total += 1
    person_ids << pbd.person_id
    puts person_ids.uniq.count
  end
end
puts person_ids
$models = {}
Rails.application.eager_load!
ActiveRecord::Base.send(:subclasses).map(&:name).each do |n|
   $models[eval(n).table_name] = n
end

person_ids.each do |pid|
 #  PersonService.fix_location_ids(pid, $models)      
end
