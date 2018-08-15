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

def new_adoptive_parent

  @person = Person.find(params[:id])

  @person_details = PersonBirthDetail.find_by_person_id(params[:id])

  @person_name = PersonName.find_by_person_id(params[:id])

  @person_mother_name = @person.mother.person_names.first rescue nil

  @person_father_name = @person.father.person_names.first rescue nil

  @section = "New Adoptive Person"

  render :layout => "touch"
end

def add_adoptive_parents

  render :layout => "touch"
end

def create_adoptive_parents

  person = Person.find(params[:person_id])
  if params[:foster_parents] == "Both" || params[:foster_parents] =="Mother"
    adoptive_mother   = Lib.new_mother(person, params, 'Adoptive-Mother')
  end

  if params[:foster_parents] == "Both" || params[:foster_parents] =="Father"
    adoptive_father   = Lib.new_father(person, params,'Adoptive-Father')
  end

  @birth_details = PersonBirthDetail.where(person_id: params[:person_id]).last
  if params[:court_order_attached] == 'Yes'
    @birth_details.court_order_attached = 1
  elsif params[:court_order_attached] == 'No'
    @birth_details.court_order_attached = 0
  end

  if params[:form_signed] == 'Yes'
    @birth_details.form_signed = 1
  elsif params[:form_signed] == 'No'
    @birth_details.form_signed = 0
  end

  @birth_details.informant_designation = (params[:person][:informant][:designation].present? ? params[:person][:informant][:designation].to_s : nil)

  if params[:informant_same_as_mother] == 'Yes'
    params[:informant_id]                                 = adoptive_mother.person_id
    @birth_details.informant_relationship_to_person       = "Adoptive-Mother"
    @birth_details.other_informant_relationship_to_person = nil
  end

  if params[:informant_same_as_father] == 'Yes'
    params[:informant_id]                                 = adoptive_father.person_id
    @birth_details.informant_relationship_to_person       = "Adoptive-Father"
    @birth_details.other_informant_relationship_to_person = nil
  end

  @birth_details.birth_registration_type_id = BirthRegistrationType.where(name: "Adopted").last.id
  @birth_details.save

  informant = Lib.new_informant(person, params)
  redirect_to "/person/#{params[:person_id]}"
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
    if params[:exact].present?
      @states = ["DC-DUPLICATE"]
       @section = "Exact Duplicates"
    else
      @states = ['FC-POTENTIAL DUPLICATE','DC-POTENTIAL DUPLICATE']
       @section = "Potential Duplicates"
    end

   #@actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states)
   @targeturl ="/manage_duplicates_menu"
    @records = [] #PersonService.query_for_display(@states)

    render :template => "/person/records", :layout => "data_table"
end

def view_hq_duplicates
    
    @states = ['DC-VERIFY DUPLICATE']
    @section = "Duplicates from HQ"
    @targeturl ="/manage_duplicates_menu"
    @records = [] #PersonService.query_for_display(@states)

    render :template => "/person/records", :layout => "data_table"
end

def potential_duplicate
  @section = "Resolve Duplicates"
  @potential_duplicate =  person_details(params[:id])
  @potential_records = PotentialDuplicate.where(:person_id => (params[:id].to_i)).last
  @similar_records = []
  @potential_records.duplicate_records.each do |record|
    @similar_records << person_details(record.person_id)
  end
  @targeturl = params[:next_path]
  render :layout => "facility"
end

def add_duplicate_comment
  render :layout => "touch"
end

def resolve_duplicate
     potential_records = PotentialDuplicate.where(:person_id => (params[:id].to_i)).last
     if potential_records.present?
        if params[:decision] == "POTENTIAL DUPLICATE"
           PersonRecordStatus.new_record_state(params[:id], params[:nextstatus], params[:reason])
           redirect_to params[:next_path]
        elsif params[:decision] == "NOT DUPLICATE"
          potential_records.resolved = 1
          potential_records.decision = params[:decision]
          potential_records.comment = params[:reason]
          potential_records.resolved_at = Time.now
          potential_records.save

          allocate_record = IdentifierAllocationQueue.new
          allocate_record.person_id = params[:id].to_i
          allocate_record.assigned = 0
          allocate_record.creator = User.current.id
          allocate_record.person_identifier_type_id = (PersonIdentifierType.where(:name => "Birth Entry Number").last.person_identifier_type_id rescue 1)
          allocate_record.created_at = Time.now
          if allocate_record.save
            PersonRecordStatus.new_record_state(params[:id], 'HQ-ACTIVE', params[:reason])
          end
          redirect_to params[:next_path]
        else
          potential_records.resolved = 1
          potential_records.decision = params[:decision]
          potential_records.comment = params[:reason]
          potential_records.resolved_at = Time.now
          potential_records.save

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
    @targeturl ="/manage_duplicates_menu"
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

    allocate_record = IdentifierAllocationQueue.new
    allocate_record.person_id = params[:id].to_i
    allocate_record.assigned = 0
    allocate_record.creator = User.current.id
    allocate_record.person_identifier_type_id = (PersonIdentifierType.where(:name => "Birth Entry Number").last.person_identifier_type_id rescue 1)
    allocate_record.created_at = Time.now
    allocate_record.save

    if ["HQ-REJECTED","DC-VERIFY DUPLICATE"].include?(old_state)
      PersonRecordStatus.new_record_state(@child.person_id, "HQ-RE-APPROVED")
    else
      PersonRecordStatus.new_record_state(@child.person_id, "HQ-ACTIVE")
    end

    render :text =>  session[:list_url]
  end

  ################################## Pending Cases actions ####################################################################
  def manage_pending_cases
    @stats = PersonRecordStatus.stats
    @icoFolder = folder
    @section = "Pending Cases"
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
    #PersonRecordStatus.new_record_state(params[:id], 'DC-PENDING', params[:reason])

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
    @states = ["DC-ACTIVE", 'DC-COMPLETE', 'DC-REJECTED']

    @abandoned = PersonRecordStatus.stats(['Abandoned'], false).reject{|k, v| !@states.include?(k)}.values.sum
    @orphaned = PersonRecordStatus.stats(['Orphaned'], false).reject{|k, v| !@states.include?(k)}.values.sum
    @adopted = PersonRecordStatus.stats(['Adopted'], false).reject{|k, v| !@states.include?(k)}.values.sum

    @icoFolder = folder
    @section = "Special Cases"
    @targeturl = "/"
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

    render :layout => "facility"
  end

  def abandoned_cases
    @states = []
    if User.current.user_role.role.role.upcase == "Logistics Officer".upcase
      @states = ['DC-ACTIVE', 'DC-PENDING', 'DC-REJECTED']
    elsif User.current.user_role.role.role.upcase == 'ADR'
      @states = ['DC-COMPLETE']
    end

    @birth_type = "Abandoned"
    #Status.all.map(&:name).each{|name|
     # @states << name if ActionMatrix.read_actions(User.current.user_role.role.role, [name]).length > 0
    #}

    #@records = PersonService.query_for_display(@states, types=['Abandoned'])
    @section = "Abandoned Cases"
    @display_ben = true
    render :template => "/person/records", :layout => "data_table"
  end

  def adopted_cases
    @states = []
    if User.current.user_role.role.role.upcase == "Logistics Officer".upcase
      @states = ['DC-ACTIVE', 'DC-PENDING', 'DC-REJECTED']
    elsif User.current.user_role.role.role.upcase == 'ADR'
      @states = ['DC-COMPLETE']
    end

    @birth_type = "Adopted"
    @section = "Adopted Cases"
    @display_ben = true
    render :template => "/person/records", :layout => "data_table"
  end

  def orphaned_cases
    @states = []
    if User.current.user_role.role.role.upcase == "Logistics Officer".upcase
      @states = ['DC-ACTIVE', 'DC-PENDING', 'DC-REJECTED']
    elsif User.current.user_role.role.role.upcase == 'ADR'
      @states = ['DC-COMPLETE']
    end

    @birth_type = "Orphaned"

    @section = "Orphaned Cases"
    @display_ben = true
    render :template => "/person/records", :layout => "data_table"
  end

  def search
  end

  def filter
    @filter = params[:filter]
    @filters = ["Birth Entry Number", "Child Name", "Child Gender",
                "Place of Birth", 'Record Status',"Date Issued"
                ]
    @statuses = Status.all.map(&:name).sort
    users = User.find_by_sql(
        "SELECT u.username, u.person_id FROM users u
          INNER JOIN user_role ur ON ur.user_id = u.user_id
          INNER JOIN role r ON r.role_id = ur.role_id
         WHERE r.level IN ('DC', 'FC')
        ")

    @users = []
    users.each do |u|
      name = PersonName.where(:person_id => u.person_id).last
      @users << [
          "#{name.first_name} #{name.middle_name} #{name.last_name} (#{u.username})".gsub(/\s+/, ' '),
          u.username
      ]
    end

  end

  def rfilter
    @filter = params[:filter]
    @filters = ["Birth Entry Number", "Facility Serial Number", "Child Name", "Child Gender",
                "Place of Birth", 'Record Status', 'Location Created'
    ]
  end

  def print_certificates
    @stats = PersonRecordStatus.stats
    @icoFolder = folder
    @section = "Print Certificates"
    @targeturl = "/"
    @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

    render :layout => "facility"
  end

  def select_cases

    facility_tag_id = LocationTag.where(name: "Health Facility").first.id
    #village_tag_id = LocationTag.where(name: "Village").first.id
    printable_statuses = Status.where("name IN ('HQ-CAN-PRINT', 'HQ-CAN-RE-PRINT')").map(&:status_id)

    @facilities = ActiveRecord::Base.connection.select_all("
      SELECT d.location_created_at, l.name, count(*) AS total FROM person_birth_details d
        INNER JOIN person_record_statuses s ON s.person_id = d.person_id AND s.voided = 0 AND s.status_id IN (#{printable_statuses.join(", ")})
        INNER JOIN location l ON l.location_id = d.location_created_at
        INNER JOIN location_tag_map m ON m.location_id = l.location_id AND m.location_tag_id = #{facility_tag_id}
      GROUP BY location_created_at
        "
    )

=begin
    @villages = PersonBirthDetail.find_by_sql("
      SELECT birth_location_id, l.name, count(*) total FROM person_birth_details d
        INNER JOIN person_record_statuses s ON s.person_id = d.person_id AND s.voided = 0 AND s.status_id IN (#{printable_statuses.join(", ")})
        INNER JOIN location l ON l.location_id = d.birth_location_id
        INNER JOIN location_tag_map m ON m.location_id = l.location_id AND m.location_tag_id = #{village_tag_id}

    "
    )

    @tas_by_count = {}
    @tas_villages = {}

    @villages.each do |v|
      village = Location.find(v)
      ta = village.ta
      @tas_by_count[ta]  = 0 if @tas_by_count[ta].blank?
      @tas_by_count[ta] += 1

      @tas_villages[ta]      = {} if @tas_villages[ta].blank?
      @tas_villages[ta][village.name] = 0 if  @tas_villages[ta][village.name].blank?
      @tas_villages[ta][village.name] += 1
    end
=end
  end
end