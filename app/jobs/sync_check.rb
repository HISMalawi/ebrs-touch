class SyncCheck
  include SuckerPunch::Job
  workers 1

  def perform()

    begin
      @database = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]
      link = "#{@database['protocol']}://#{@database['username']}:#{@database['password']}@#{@database['host']}:#{@database['port']}/_active_tasks"

      tasks = JSON.parse(%x[curl  #{link}]) rescue []

      if tasks.length  >= ({"DC" => 2, "FC" => 1}[SETTINGS['application_mode']]) #DC is two way, FC is one way
        FileUtils.touch("#{Rails.root}/public/sync_sentinel")
      else
        load "#{Rails.root}/bin/sync.rb"
      end
    rescue
      SyncCheck.perform_in(60)
    end

    SyncCheck.perform_in(60)
  end
end
