class CouchSQL
  include SuckerPunch::Job
  workers 1

  def perform()
    begin
      load "#{Rails.root}/bin/couch-mysql.rb"
    rescue => e
      puts "#{e.to_s}"
      CouchSQL.perform_in(5)
    end
  end

  CouchSQL.perform_in(2)
end

