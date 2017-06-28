class DcController < ApplicationController

def new_registration

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
  @targettext = "Home"

  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)
  render :layout => "facility"
end

def manage_requests
  @icoFolder = folder
  @section = "Manage Ammnendments"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

def manage_duplicates_menu
  @icoFolder = folder
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  @section = "Manage Duplicates"
  render :layout => "facility"
end

end