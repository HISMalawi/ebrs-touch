class DcController < ApplicationController

def new_registration
  raise application_mode.inspect
    @icoFolder = folder

    @section = "Register Person"

    #reset_page_sessions()

    @form_action = "/person/new"

    render :layout => "touch"
end

def manage_cases
  @icoFolder = folder
  @section = "Manage Cases"
  @targeturl = "/"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

def manage_requests
  @icoFolder = folder
  @section = "Manage Ammendments"
  @targeturl = "/"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

def manage_duplicates_menu
  @icoFolder = folder
  @section = "Manage Duplicates"
  @targeturl = "/"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

end