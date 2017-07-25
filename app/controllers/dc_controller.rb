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
  @section = "Ammendments"
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

def view_duplicates
    @states = ['FC-POTENTIAL DUPLICATE','DC-POTENTIAL DUPLICATE','DC-DUPLICATE']
    @section = "Potential Duplicates"
   #@actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)

    render :template => "dc/view_duplicates", :layout => "data_table"
end

def potential_duplicate
  @section = "Resolve Duplicates"
  @potential_duplicate =  person_details(params[:id])
  @potential_records = PotentialDuplicate.where(:person_id => (params[:id].to_i)).last
  @similar_records = []
  @potential_records.duplicate_records.each do |record|
    @similar_records << person_details(record.person_id)
  end
  render :layout => "facility"
end

def add_duplicate_comment
  render :layout => "touch"
end

def resolve_duplicate

     potential_records = PotentialDuplicate.where(:person_id => (params[:id].to_i)).last
     if potential_records.present?
        potential_records.resolved = 1
        potential_records.decision = params[:decision]
        potential_records.comment = params[:reason]
        potential_records.resolved_at = Time.now
        potential_records.save


        if params[:decision] == "NOT DUPLICATE"
           PersonRecordStatus.new_record_state(params[:id], 'HQ-ACTIVE', params[:reason])
           redirect_to params[:next_path]
        else
           PersonRecordStatus.new_record_state(params[:id], 'DC-VOIDED', params[:reason])
           redirect_to params[:next_path]
        end
    else
      redirect_to params[:next_path]
     end
end

def duplicates
    @states = ['DC-VOIDED']
    @section = "Resolved Duplicates"
   # @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)

    @records = PersonService.query_for_display(@states)

    render :template => "dc/view_duplicates", :layout => "data_table"
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
      allocate_record = IdentifierAllocationQueue.new
      allocate_record.person_id = params[:id].to_i
      allocate_record.assigned = 0
      allocate_record.creator = User.current.id
      allocate_record.person_identifier_type_id = (PersonIdentifierType.where(:name => "Birth Entry Number").last.person_identifier_type_id rescue 1)
      allocate_record.created_at = Time.now
      if allocate_record.save
        PersonRecordStatus.new_record_state(params[:id], 'HQ-ACTIVE', params[:reason])
      end
    end

    render :text => "/view_pending_cases" and return if old_state == "DC-PENDING"
    render :text =>  "/view_complete_cases"
  end

  ################################## Pending Cases actions ####################################################################
  def manage_pending_cases
    @stats = PersonRecordStatus.stats
    @icoFolder = folder
    @section = "Manage Pending Cases"
    @targeturl = "/"
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

    render :layout => "facility"
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

  ############################################################################################################################
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

  #################### Actions for special Cases ####################################################################################
  def special_cases
    @stats = PersonRecordStatus.stats
    @icoFolder = folder
    @section = "Special Cases"
    @targeturl = "/"
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

    render :layout => "facility"
  end
end