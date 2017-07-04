class DcController < ApplicationController

def new_registration
    @icoFolder = folder

    @section = "Register Person"

    #reset_page_sessions()

    @form_action = "/person/new"

    render :layout => "touch"
end

def manage_cases
  @stats = PersonRecordStatus.stats
  @icoFolder = folder
  @section = "Manage Cases"
  @targeturl = "/"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

def manage_requests
  @stats = PersonRecordStatus.stats
  @icoFolder = folder
  @section = "Manage Ammendments"
  @targeturl = "/"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

def manage_duplicates_menu
  @stats = PersonRecordStatus.stats
  @icoFolder = folder
  @section = "Manage Duplicates"
  @targeturl = "/"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

  def incomplete_case_comment

    @child_id = params[:id]

    @form_action = "/incomplete_case"

    @section = "Reason for incompleteness"

    render :layout => "touch"

  end

  def complete_case_comment

    PersonRecordStatus.new_record_state(params[:id], 'DC-COMPLETE', params[:reason])

    redirect_to "/view_cases"

  end

  def incomplete_case
    PersonRecordStatus.new_record_state(params[:id], 'DC-INCOMPLETE', params[:reason])

    flash[:info] = "Record is not complete"
    if User.current.user_role.role.role.downcase == 'adr'
      redirect_to "/view_complete_cases"
    else
      redirect_to "/view_cases"
    end
  end

  def ajax_approve
    @child = Person.find(params[:id])
    @birth_details = PersonBirthDetail.find_by_person_id(params[:id])
    old_state = PersonRecordStatus.status(params[:id])

    if PersonService.record_complete?(@child) == false
      flash[:info] = "Record is not complete"
    else
      PersonRecordStatus.new_record_state(params[:id], 'HQ-ACTIVE', params[:reason])
    end

    render :text => "/view_pending_cases" and return if old_state == "DC-PENDING"
    render :text =>  "/view_complete_cases"
  end

  def pending_case_comment
    @child = Person.find(params[:id])
    @form_action = "/pending_case"
    @section = "Reason for pending record"

    render :layout => "touch"
  end

  def pending_case
    PersonRecordStatus.new_record_state(params[:id], 'DC-PENDING', params[:reason])

    if User.current.user_role.role.role.downcase == 'adr'
      redirect_to "/view_complete_cases"
    else
      redirect_to "/view_cases"
    end
  end

  def reject_case_comment
    @child = Person.find(params[:id])
    @form_action = "/reject_case"
    @section = "Reason for rejecting record"

    render :layout => "touch"
  end

  def reject_case
    PersonRecordStatus.new_record_state(params[:id], 'DC-REJECTED', params[:reason])

    if User.current.user_role.role.role.downcase == 'adr'
      redirect_to "/view_complete_cases"
    else
      redirect_to "/view_cases"
    end
  end

  def comments
    messages = PersonRecordStatus.where("person_id = #{params[:id]} AND COALESCE(comments, '') != '' ").order("created_at DESC")
    msg ="<ul>"

    messages.each do |message|
      user = User.find(message.creator)
      msg = "#{msg}<li>User: #{user.username},  Message: #{message.comments},  Date : #{message.created_at.strftime('%e/%b/%Y')}</li>"
    end
    msg = "#{msg}</ul>"
    render :text => msg
  end

end