class ReportsController < ApplicationController
  def index
    @icoFolder = folder
    @section = "Reports"
    @targeturl = "/"
     @stats = {}
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

     render :layout => "facility"
  end
end
