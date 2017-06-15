# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#=begin

begin
    ActiveRecord::Base.transaction do
      require Rails.root.join('db','load_person_types.rb')
      require Rails.root.join('db','load_person_relationship_types.rb')
    end
rescue => e
	puts "Error ::::  #{e.message}  ::  #{e.backtrace.inspect}"
end

person_type = PersonType.where(name: 'User').first

core_person = CorePerson.create(person_type_id: person_type.id)
person_name = PersonName.create(person_id: core_person.person_id,
  first_name: 'System', last_name: 'Admin')

person_name_code = PersonNameCode.create(person_name_id: person_name.person_name_id,
  first_name_code: 'System'.soundex, last_name_code: 'Admin'.soundex )

[['Administrator', 1], ['Nurse', 2], ['Midwife', 2], ['Data clerk', 3]].each do |r, l|
  Role.create(role: r, level: l)
end

role = Role.where(role: 'Administrator').first

user = User.create(username: 'admin',
  password: 'adminebrs',
  creator: 1, person_id: core_person.person_id)

UserRole.create(user_id: user.id, role_id: role.id)

loc_tags = ['Country','District','Village','Traditional Authority','Health facility']
loc_tags.each do |t|
  LocationTag.create(name: t)
end

#=end

User.current = User.first

begin
  ActiveRecord::Base.transaction do
    require Rails.root.join('db','load_countries.rb')
    require Rails.root.join('db','load_districts.rb')
    require Rails.root.join('db','load_tas_and_villages.rb')
    require Rails.root.join('db','load_health_facilities.rb')
  end
rescue => e
	puts "Error ::::  #{e.message}  ::  #{e.backtrace.inspect}"
end



puts "Successful created: your new username is: #{user.username}  and password: adminebrs"
