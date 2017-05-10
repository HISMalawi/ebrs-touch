# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


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


