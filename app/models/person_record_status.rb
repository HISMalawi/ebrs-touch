class PersonRecordStatus < ActiveRecord::Base
    self.table_name = :person_record_statuses
    self.primary_key = :person_record_status_id
    include EbrsAttribute

    belongs_to :person, foreign_key: "person_id"
    belongs_to :status, foreign_key: "status_id"

  def self.new_record_state(person_id, state, change_reason='', user_id=nil)
    ActiveRecord::Base.transaction do
    if user_id.blank?
      if User.current.present?
        user_id = User.current.id
      else
        user_id = User.where(username: "admin#{SETTINGS['location_id']}").last.id
      end
    end

    state_id = Status.where(:name => state).first.id
    trail = self.where(:person_id => person_id, :voided => 0)
    trail.each do |state|
      state.update_attributes(
          voided: 1, 
          date_voided: Time.now,
          voided_by: user_id
      )
    end

    self.create(
        person_id: person_id,
        status_id: state_id,
        voided: 0,
        creator: user_id,
        comments: change_reason
    )
    end
  end

  def self.status(person_id)
    self.where(:person_id => person_id).order(" created_at, person_record_status_id ").last.status.name rescue ""
  end

  def self.type_stats(states=nil, old_state=nil, old_state_creator=nil)
      result = {}
      return result if states.blank?
      had_query = ''

      if old_state.present?

        prev_status_ids = Status.where(" name IN ('#{old_state.split("|").join("', '")}')").map(&:status_id)
        had_query = "INNER JOIN person_record_statuses prev_s ON prev_s.person_id = s.person_id AND prev_s.status_id IN (#{prev_status_ids.join(', ')})"

        if old_state_creator.present?
          user_ids = UserRole.where(role_id: Role.where(role: old_state_creator).last.id).map(&:user_id)
          user_ids = [-1] if user_ids.blank?

          had_query += " AND prev_s.creator IN (#{user_ids.join(', ')})"
        end
      end

      status_ids = states.collect{|s| Status.where(name: s).last.id} rescue Status.all.map(&:status_id)

      faulty_ids = [-1] + PersonRecordStatus.find_by_sql("SELECT prs.person_record_status_id FROM person_record_statuses prs
                                                LEFT JOIN person_record_statuses prs2 ON prs.person_id = prs2.person_id AND prs.voided = 0 AND prs2.voided = 0
                                                WHERE prs.created_at < prs2.created_at;").map(&:person_record_status_id)

      data = self.find_by_sql("
      SELECT t.name, COUNT(*) c FROM person_birth_details d
        INNER JOIN person_record_statuses s ON d.person_id = s.person_id
        INNER JOIN birth_registration_type t ON t.birth_registration_type_id = d.birth_registration_type_id
          #{had_query}
        WHERE s.voided = 0 AND s.person_record_status_id NOT IN (#{faulty_ids.join(', ')}) AND s.status_id IN (#{status_ids.join(', ')}) GROUP BY d.birth_registration_type_id")


      (data || []).each do |r|
        result[r['name']] = r['c']
      end
      result
  end

  def self.stats(types=['Normal', 'Adopted', 'Orphaned', 'Abandoned'], approved=true)
    return JSON.parse(File.read("#{Rails.root}/tmp/stats.json"))
  end

  def self.trace_data(person_id)
    return [] if person_id.blank?
    result = []
    PersonRecordStatus.where(person_id: person_id).order("created_at DESC").each do |status|
	    user = User.find(status.creator) rescue nil
			action = "Status changed to:  '#{status.status.name.titleize.gsub(/^Hq/, "HQ").gsub(/^Dc/, 'DC').gsub(/^Fc/, 'FC')}'"
			if status.status.name.upcase == "DC-ACTIVE"
				action  = "New Record Created"
			elsif status.status.name.upcase == "HQ-ACTIVE"
				action = "Record Approved By ADR"
			end

      result << {
          "date" => status.created_at.strftime("%d-%b-%Y"),
          "time" => status.created_at.strftime("%I:%M %p"),
	  "site" => (user.user_role.role.level rescue ''),
          "action" => action,
	  "user"   => ("#{user.first_name} #{user.last_name} <br /> <span style='font-size: 0.8em;'><i>(#{user.user_role.role.role})</i></span>" rescue ''),
          "comment" => status.comments
      }
    end

    result
  end
end
