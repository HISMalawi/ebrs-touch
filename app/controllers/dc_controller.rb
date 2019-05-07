class DcController < ApplicationController

def new_registration
    @icoFolder = folder

    if User.current.user_role.role.role == "Data Supervisor"
      redirect_to "/person/new?utf8=✓&id=&relationship=Normal" and return
    end

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

def printed_cases
  @stats = PersonRecordStatus.stats
  @icoFolder = folder
  @section = "Printed Cases"
  @targeturl = "/"
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :layout => "facility"
end

def above_16_abroad
  @stats = PersonRecordStatus.stats
  @icoFolder = folder
  @section = "Above 16 (Abroad)"
  @targeturl = "/"
  @states = Status.all.pluck :name
  @display_ben = true
  @display_ver_num = true
  @folders = ActionMatrix.read_folders(User.current.user_role.role.role)

  render :template => "/person/records", :layout => "data_table"
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
      session[:exact_duplicate] = true
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

  @targeturl = request.referrer
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

          PersonRecordStatus.new_record_state(params[:id], 'DC-COMPLETE', params[:reason])
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
	
	year = Date.today.year
	ben  = @birth_details.generate_ben(year)

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
    ).collect{|c| [c['location_created_at'], c['name'], c['total']]}

    render :layout => "touch"
  end

def villages

end

def print_certificates

  @type_stats = PersonRecordStatus.type_stats(['HQ-CAN-PRINT', "HQ-CAN-RE-PRINT"], params[:had], params[:had_by])
  facility_tag_id = LocationTag.where(name: "Health Facility").first.id
  district_tag_id = LocationTag.where(name: "District").first.id

  printable_statuses = Status.where("name IN ('HQ-CAN-PRINT', 'HQ-CAN-RE-PRINT')").map(&:status_id)

  @facilities = ActiveRecord::Base.connection.select_all("
        SELECT d.location_created_at, l.name FROM person_birth_details d
          INNER JOIN location l ON l.location_id = d.location_created_at
          INNER JOIN location_tag_map m ON m.location_id = l.location_id AND m.location_tag_id = #{facility_tag_id}
        GROUP BY location_created_at
          "
  ).collect{|c| [c['location_created_at'], c['name']]}

  @districts = ActiveRecord::Base.connection.select_all("
        SELECT l.location_id, l.name FROM location_tag_map m
          INNER JOIN location l ON l.location_id = m.location_id
          WHERE m.location_tag_id = #{district_tag_id}
        GROUP BY l.location_id
          "
  ).collect{|c| [c['location_id'], c['name']]}

  cur_loc_id = SETTINGS['location_id']
  cur_loc_name = Location.find(cur_loc_id).name

  @facilities << [cur_loc_id, "#{cur_loc_name} (ADR)"]

  params[:statuses] = [] if params[:statuses].blank?
  session[:list_url] = request.referrer
  @states = params[:statuses]
  @states = ["HQ-CAN-PRINT", "HQ-CAN-RE-PRINT"] if @states.blank?

  @icoFolder = folder
  @section = "Print Certificates"
  @targeturl = "/"

  @actions = ActionMatrix.read_actions(User.current.user_role.role.role, @states) rescue []
  types = []

  @birth_type = params[:birth_type]

  search_val = params[:search][:value] rescue nil
  search_val = '_' if search_val.blank?
  search_category = ''

  if !params[:category].blank?

    if params[:category] == 'continuous'
      search_category = " AND (pbd.source_id IS NULL OR LENGTH(pbd.source_id) >  19)  "
    elsif params[:category] == 'mass_data'
      search_category = " AND (pbd.source_id IS NOT NULL AND LENGTH(pbd.source_id) <  20 ) "
    else
      search_category = ""
    end

    session[:category] = params[:category]
  end

  if !params[:start].blank?

    loc_query = " "
    locations = []

    if params[:district] == "All"
      session[:district] = ""
    end

    if params[:district].present? && params[:district] != "All"
      session[:district] = params[:district]

      locations = [params[:district]]

      facility_tag_id = LocationTag.where(name: 'Health Facility').first.id rescue [-1]
      (Location.find_by_sql("SELECT l.location_id FROM location l
                            INNER JOIN location_tag_map m ON l.location_id = m.location_id AND m.location_tag_id = #{facility_tag_id}
                          WHERE l.parent_location = #{params[:district]}") || []).each {|l|
        locations << l.location_id
      }
      loc_query = " AND pbd.location_created_at IN (#{locations.join(', ')}) "
    end

    facility_filter = ""
    if !params[:facility_id].blank? && params[:facility_id] != "All"
      session[:facility_id] = params[:facility_id]
      facility_filter = " AND pbd.location_created_at = #{params[:facility_id]} "
    else
      session[:facility_id] = ""
    end

    state_ids = @states.collect{|s| Status.find_by_name(s).id} + [-1]
    types=['Normal', 'Abandoned', 'Adopted', 'Orphaned'] if params[:type] == 'All'
    types=['Abandoned', 'Adopted', 'Orphaned'] if params[:type] == 'All Special Cases'
    types=[params[:type]] if types.blank?

    person_reg_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

    had_query = ' '
    if !params['had'].blank?
      #probe user who made previous change
      user_hook = ""
      if params['had_by'].present?

        had_by_users =  UserRole.where(role_id: Role.where(role: params['had_by']).last.id).map(&:user_id) rescue [-1]
        had_by_users =  [-1] if had_by_users.blank?
        user_hook = " AND prev_s.creator IN (#{had_by_users.join(', ')}) " if had_by_users.length > 0
      end

      prev_states = params['had'].split('|')
      prev_state_ids = prev_states.collect{|sn| Status.where(name: sn).last.id  rescue -1 }
      had_query = " INNER JOIN person_record_statuses prev_s ON prev_s.person_id = prs.person_id #{user_hook}
             AND prev_s.status_id IN (#{prev_state_ids.join(', ')})"
    end

    informant_join_query = "  "
    if !params[:informant_village].blank? && !params[:informant_ta].blank? && !params[:informant_district].blank?

      district_id          = Location.locate_id_by_tag(params[:informant_district], "District")
      ta_id                = Location.locate_id(params[:informant_ta], "Traditional Authority", district_id)
      village_id           = Location.locate_id(params[:informant_village], "Village", ta_id)

      village_filter_query = " " #" AND pbd.location_created_at  = #{village_id}"

      info_type_id         = PersonRelationType.where(name: "Informant").first.id
      informant_join_query = "INNER JOIN person_relationship p_rel ON p_rel.person_a = person.person_id
                                AND p_rel.person_relationship_type_id = #{info_type_id}
                              INNER JOIN person_addresses info_a ON info_a.person_id = p_rel.person_b
                                AND ((info_a.current_district = #{district_id}
                                      AND info_a.current_ta = #{ta_id}
                                      AND info_a.current_village  = #{village_id})
                                        OR
                                      (pbd.location_created_at  = #{village_id}))
                              "

    end

    #faulty_ids = [-1] + PersonRecordStatus.find_by_sql("SELECT prs.person_record_status_id FROM person_record_statuses prs
     #                                           LEFT JOIN person_record_statuses prs2 ON prs.person_id = prs2.person_id AND prs.voided = 0 AND prs2.voided = 0
       #                                         WHERE prs.created_at < prs2.created_at;").map(&:person_record_status_id)

    d = Person.order(" pbd.district_id_number, pbd.national_serial_number, n.first_name, n.last_name, cp.created_at ")
    .joins(" INNER JOIN core_person cp ON person.person_id = cp.person_id
              INNER JOIN person_name n ON person.person_id = n.person_id
              INNER JOIN person_record_statuses prs ON person.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
              #{had_query}
              INNER JOIN person_birth_details pbd ON person.person_id = pbd.person_id
              #{informant_join_query}
    ")
    .where(" prs.status_id IN (#{state_ids.join(', ')}) AND n.voided = 0
              #{village_filter_query}
              AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')}) #{loc_query} #{facility_filter}
              AND concat_ws('_', pbd.national_serial_number, pbd.district_id_number, n.first_name, n.last_name, n.middle_name,
              person.birthdate, person.gender) REGEXP \"#{search_val}\"  #{search_category} ")

    total = d.select(" count(*) c ")[0]['c'] rescue 0
    page = (params[:start].to_i / params[:length].to_i) + 1

    data = d.group(" prs.person_id ")

    data = data.select(" n.*, prs.status_id, pbd.district_id_number AS ben, person.gender, person.birthdate, pbd.national_serial_number AS brn")
    data = data.page(page)
    .per_page(params[:length].to_i)

    @records = []
    nid_data = []
    data.each do |p|
      mother = PersonService.mother(p.person_id)
      father = PersonService.father(p.person_id)
      details = PersonBirthDetail.find_by_person_id(p.person_id)

      p['first_name'] = '' if p['first_name'].present? && p['first_name'].match('@')
      p['last_name'] = '' if p['last_name'].present? && p['last_name'].match('@')
      p['middle_name'] = '' if p['middle_name'].present? && p['middle_name'].match('@')

      name          = ("#{p['first_name']} #{p['middle_name']} #{p['last_name']}")
      mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
      father_name   = ("#{father.first_name rescue 'N/A'} #{father.middle_name rescue ''} #{father.last_name rescue ''}")

      arr = [
          p.ben
          ]

      national_id = p.id_number rescue ""
      arr  << (national_id)

      arr = arr + [name,
                   p.birthdate.strftime('%d/%b/%Y'),
                   p.gender,
                   mother_name,
                   father_name,
                   Status.find(p.status_id).name.sub("HQ-CAN-PRINT", "CAN-PRINT"),
                   p.person_id
      ]

      @records << arr
    end

    render :text => {
        "draw" => params[:draw].to_i,
        "recordsTotal" => total,
        "recordsFiltered" => total,
        "data" => @records}.to_json and return
  end

  @online = false
  require 'open3'
  host, port = SETTINGS['sync_host'].split(":")
  a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
  if b.scan(/succeeded/).length > 0
    @online = true
  end

  render :template => "/dc/records", layout: "bootstrap_data_table"
 end

 def records
    person_type = PersonType.where(name: 'Client').first
    @records = Person.where("p.person_type_id = ?",
                            person_type.id).joins("INNER JOIN core_person p ON person.person_id = p.person_id
        INNER JOIN person_name n
        ON n.person_id = p.person_id").group('n.person_id').select("person.*, n.*").order('p.created_at DESC')

    render :layout => 'data_table'
 end

  def check_print_rules
    person_ids = params[:person_ids]

    #Check for missing barcode and assign one from remote
    barcode_number_id = PersonIdentifierType.where(name: "Barcode Number").first.id
    missing_barcodes_person_ids = PersonBirthDetail.find_by_sql(
        "SELECT pbd.person_id FROM person_birth_details pbd
          LEFT JOIN person_identifiers pid ON pid.person_id = pbd.person_id AND pid.person_identifier_type_id = #{barcode_number_id}
          WHERE pid.person_id IS NULL AND pbd.person_id IN (#{person_ids})
        ").map(&:person_id).uniq

    if missing_barcodes_person_ids.length > 0
      #query for assignment of missing barcode
      hq_link = SETTINGS["destination_app_link"] + "/check_print_rules?person_ids=#{missing_barcodes_person_ids.join(',')}"
      ids = JSON.parse(RestClient.get(hq_link))

      ids.each do |hash|
        PersonIdentifier.create(hash)
      end
    end

    render :text => "OK"
  end

end
