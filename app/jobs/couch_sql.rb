require "yaml"
require 'mysql2'
require 'couch_tap'

class CouchSQL
  include SuckerPunch::Job
  workers 1

  def perform()
    puts `cd #{Rails.root} && couch_tap bin/couch-mysql.rb >> log/couch_tap.log 2>> log/couch_tap.log`
  end rescue CouchSQL.perform_in(10)
end

