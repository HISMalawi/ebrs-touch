year = ARGV[0]
year = Date.today.year if year.blank?

ActiveRecord::Base.connection.execute <<EOF
    CREATE TABLE IF NOT EXISTS `ben_counter_#{year}` (
      `counter` BIGINT(20) NOT NULL AUTO_INCREMENT,
      `person_id` BIGINT(20) NOT NULL,
      `created_at`  TIMESTAMP NOT NULL,
      PRIMARY KEY (`counter`),
      UNIQUE INDEX `counter_UNIQUE` (`counter` ASC),
	  UNIQUE INDEX `pid_UNIQUE` (`person_id` ASC)
	);
EOF

last_counter = ActiveRecord::Base.connection.select_one("SELECT MAX(counter) AS counter FROM ben_counter_#{year}").as_json['counter']
if last_counter.blank?
	#Set last ben from birth details
	last_ben = ActiveRecord::Base.connection.select_one("SELECT MAX(district_id_number) AS ben FROM person_birth_details WHERE district_id_number LIKE '%/%/%#{year}' ").as_json['ben'];

	if !last_ben.blank? 	
		counter = last_ben.split("/")[1].to_i
		person_id = ActiveRecord::Base.connection.select_one("SELECT person_id FROM person_birth_details WHERE district_id_number = '#{last_ben}' ").as_json['person_id'];
		
		puts "Query Execution:  INSERT INTO ben_counter_#{year}(counter, person_id) VALUES (#{person_id}, #{counter})"
		ActiveRecord::Base.connection.execute("INSERT INTO ben_counter_#{year}(counter, person_id) VALUES (#{counter}, #{person_id})")
	end 
end 


