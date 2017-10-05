class CouchSQL
  include SuckerPunch::Job
  workers 1

  def perform()
    begin
      FileUtils.touch("#{Rails.root}/public/tap_sentinel")

      load "#{Rails.root}/bin/couch-mysql.rb"
    rescue => e
      SuckerPunch.logger.info "=========Error #{e.to_s}"
      CouchSQL.perform_in(2)
    end

    CouchSQL.perform_in(2)
  end


end

