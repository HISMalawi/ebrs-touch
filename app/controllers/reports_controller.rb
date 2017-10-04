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

  private
  def get_filters
      filters = ["Date Reported Range"]
      if SETTINGS["application_mode"] == "DC"
        @district = Location.find(SETTINGS["location_id"]).name
        filters << "Record Status"
        filters << "Date Registered Range"
        filters << "Hospital of Birth"
        filters << "Age"
      end
      
  end
end
