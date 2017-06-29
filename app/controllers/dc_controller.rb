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

  def incomplete_case_comment

    @child_id = params[:id]

    @form_action = "/incomplete_case"

    @section = "Reason for incompleteness"

    render :layout => "touch"

  end

  def complete_case_comment

    @child_id = params[:id]

    child = Child.find(@child_id)

    if child.request_status == "ACTIVE"
      redirect_to "/check_completeness/#{child.id}" and return
    else
      @form_action = "/check_completeness/#{@child_id}"

      @section = "Completeness Comment"

      render :layout => "touch"

    end

  end

  def incomplete_case
    PersonRecordStatus.new_record_state(params[:id], 'DC-INCOMPLETE', params[:reason])

    flash[:info] = "Record is not complete"
    if User.current.user_role.role.role.downcase == 'adr'
      redirect_to "/view_complete_cases"
    else
      redirect_to "/view_incomplete_cases"
    end
  end

def approve

  @child = Person.find(params[:id])

  if PersonService.record_complete?(@child) == false
    flash[:info] = "Record is not complete"
    redirect_to "/incomplete_case_comment?id=#{@child.id}" && return
  end


  months_gone = (Date.today.year * 12 + Date.today.month) - (@child.acknowledgement_of_receipt_date.to_date.year * 12 + @child.acknowledgement_of_receipt_date.to_date.month)
  old_state = @child.request_status.to_s.strip.upcase
  if @child.district_id_number.blank?

    result = false

    while !result do

      result = DistrictNumber.assign_district_number(@child, application_codes("district").to_s, Date.today.year, current_user.id)

      break if result

      sleep 1

    end

    if result == false
      flash[:info] = "Record has not been approved"
    else
      flash[:info] = "Record has been approved"
      Audit.create(record_id: @child.id, audit_type: "Audit", level: "Child", reason: "Approved child record")
      checkCreatedSync(params[:id], "HQ OPEN", @child.request_status)
    end
  else
    if @child.request_status.upcase == 'REJECTED'

      @child.update_attributes({:approved => 'Yes',
                                :record_status => "HQ OPEN",
                                :approved_by => current_user.id,
                                :request_status => 'RE-APPROVED',
                                :approved_at => Time.now()})

      Audit.create(record_id: @child.id, audit_type: "Audit", level: "Child", reason: "Re-approved child record")
      flash[:info] = "Record has been re-approved"
      checkCreatedSync(params[:id], "HQ OPEN", "RE-APPROVED")

    end
  end


  redirect_to "/#{params[:next_path]}" and return unless params[:next_path].blank?
  redirect_to "/view_pending_cases" and return if old_state == "PENDING"
  redirect_to "/view_complete_cases"
end

end