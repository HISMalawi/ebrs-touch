class SyncCheck
  include SuckerPunch::Job
  workers 1

  def perform()
    config.log_level = :error
    begin
      load "#{Rails.root}/bin/sync.rb"
      FileUtils.touch("#{Rails.root}/public/sync_sentinel")
    rescue
      SyncCheck.perform_in(2*60)
    end

    SyncCheck.perform_in(2*60)
  end rescue (SyncCheck.perform_in(2*60))
end
