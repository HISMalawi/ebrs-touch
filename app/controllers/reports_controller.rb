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
    status = params[:status]
    
    @data = Report.births_report(params[:start_date], params[:end_date],status)
    @section = "Births Report"
    @targeturl = "/"

    render :layout => "facility"
  end

  def report_date_range
    @section = "Report range"
    @targeturl = "/"
    render :layout => "touch"
  end
end
