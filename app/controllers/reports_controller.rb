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

    @data = Report.births_report(params[:start_date], params[:end_date],status)
    render :layout =>false
  end

  def report_date_range
    @section = "Report range"
    @targeturl = "/"
    render :layout => "touch"
  end

  def filter
    @filter = params[:filter]
    @filters = filters
    @statuses = Status.all.map(&:name)
    users = User.find_by_sql(
        "SELECT u.username, u.person_id FROM users u
          INNER JOIN user_role ur ON ur.user_id = u.user_id
          INNER JOIN role r ON r.role_id = ur.role_id
         WHERE r.level IN ('DC', 'FC')
        ")
  end

  def rfilter
      @filters = filters
  end

  private
  def filters
      ["Hospital of Birth", "Record Status","Date Registration Range"]
  end
end
