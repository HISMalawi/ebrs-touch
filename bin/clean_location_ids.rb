puts Pusher

=begin

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
=end

site_code = SETTINGS['location_id']
person_ids = PersonBirthDetail.where(" location_created_at = #{site_code} AND person_id NOT LIKE '100#{site_code}%' AND DATE(created_at) BETWEEN '2019-04-25' AND '#{Date.today.to_s}'").order("created_at").map(&:person_id)

puts person_ids
puts "#{person_ids.count}"

$models = {}
Rails.application.eager_load!
ActiveRecord::Base.send(:subclasses).map(&:name).each do |n|
   $models[eval(n).table_name] = n
end
raise "STOPPED".to_s
h = {}
person_ids.each do |pid|
	new_person_id = PersonService.fix_location_ids(pid, $models)  rescue next 
	if !new_person_id.blank?
		h[person_id] = new_person_id
	end   
end

File.open("fixed_records_#{SETTINGS['location_id']}", "w"){|f| f.write(h.to_json)}


