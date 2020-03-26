puts "Loading Couch to Mysql......."
puts `cd #{Rails.root} && couch_tap bin/couch-mysql.rb >> log/couch_tap.log 2>> log/couch_tap.log`
