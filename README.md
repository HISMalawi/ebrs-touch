# eBRS-HQ-2.0i

Initial Setup Instructions

1. Usual Things
   	-Copy all .yml.example files in config to .yml files
	-Specify the required paramters in the yml files
	
2. Run bundle install --local
3. Create the specified couch databases manually in couch db (This will later be removed; app to be doing this automatically)
4. Run the following in the sequence provided
	bundle exec rake db:create db:schema:load

4. Load the file using command while at root, put sql login details
    mysql -u user -p ebrs_sql < metadata.sql

5. Sync data from hq to couchDB; DONT MAKE SYNC CONTINOUS

6. Run command to seed user
   bundle exec rake db:seed

7. Redo do sync using CONTINUOUS MODE

Good Luck!!

