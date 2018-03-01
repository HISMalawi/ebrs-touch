class ReportsController < ApplicationController
  def index
    @icoFolder = folder
    @section = "Reports"
    @targeturl = "/"
     @stats = {}
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

     render :layout => "facility"
  end

  def births_report

    @section = "Births Report"
    @targeturl = "/"

    render :layout => "facility"
  end

  def report
    status = (params[:status].present? ? params[:status] : "Reported")

    @data = Report.births_report(params)
    render :layout =>false
  end

  def report_date_range
    @section = "Report range"
    @targeturl = "/"
    render :layout => "touch"
  end

  def filter
    @filter = params[:filter]
    @filters = get_filters
    @statuses = Status.all.map(&:name)
    users = User.find_by_sql(
        "SELECT u.username, u.person_id FROM users u
          INNER JOIN user_role ur ON ur.user_id = u.user_id
          INNER JOIN role r ON r.role_id = ur.role_id
         WHERE r.level IN ('DC', 'FC')
        ")
  end

  def rfilter

      @filters = get_filters
  end

  def user_audit_trail
    @section = "User audit trail"
    render :layout => "data_table"
  end

  def get_user_audit_trail
    start_date        = params[:start_date].to_date.strftime('%Y-%m-%d 00:00:00') rescue nil
    end_date          = params[:end_date].to_date.strftime('%Y-%m-%d 23:59:59') rescue nil

    records = Report.user_audits(nil,nil,start_date,end_date)

    render text: records.to_json
  end

  def dispatch_note
     @records = Report.dispatch_note(params[:start_date], params[:end_date])
     render :layout => "data_table"
  end

  def view_dispatches
    date = params[:date]

    if !date.blank?
      @records = Report.dispatched_records(params[:date], nil, nil).sort
    else
      @records = Report.dispatched_records(nil, params[:start_date], params[:end_date]).sort
    end

    path = "#{Rails.root}/public/#{@records[0 .. 5].join(',')}.pdf"

    cmd = "wkhtmltopdf 	--orientation landscape --page-size A4 http://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/dispatch_list?person_ids=#{@records.join(',')} #{path}\n"

    Kernel.system(cmd)
    @path = path
    @file = File.read(path)

    File.open(@path, 'r') do |f|
      send_data f.read.force_encoding('BINARY'), :filename => path, :type => "application/pdf", :disposition => "attachment"
    end

    #render :layout => "data_table"
  end

  def dispatch_list
    return [] if params[:person_ids].blank?

    @people = Person.find_by_sql("SELECT n.*, p.gender, p.birthdate, d.national_serial_number, d.district_id_number, d.date_registered, d.location_created_at FROM person p
                                 INNER JOIN person_birth_details d ON d.person_id = p.person_id
                                 INNER JOIN person_name n ON n.person_id = p.person_id
                        WHERE d.person_id IN (#{params[:person_ids]}) ")
    @districts = []

    @data = []
    @people.each do |p|

      @districts <<  Location.find(@people.first.location_created_at).district
      details = PersonBirthDetail.where(:person_id => p.person_id).last

      @data << {
          'name'                => p.name,
          'brn'                 => details.brn,
          'ben'                 => details.ben,
          'dob'                 => p.birthdate.to_date.strftime('%d/%b/%Y'),
          'sex'                 => p.gender,
          'place_of_birth'      => details.birthplace,
          'date_registered'     => (p.date_registered.to_date.strftime('%d/%b/%Y') rescue nil)
      }
    end

    @districts = @districts.uniq
    @district = @districts.join(", ")

    render :layout => false
  end

  private
  def get_filters
      filters = ["Date Reported Range"]
      if SETTINGS["application_mode"] == "DC"
        @district = Location.find(SETTINGS["location_id"]).name
        filters << "Record Status"
        filters << "Date Registered Range"
        filters << "Place of Birth"
        filters << "Age"
      end
      return filters
  end
end
