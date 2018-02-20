class PersonRecordStatus < ActiveRecord::Base
    self.table_name = :person_record_statuses
    self.primary_key = :person_record_status_id
    include EbrsAttribute

    belongs_to :person, foreign_key: "person_id"
    belongs_to :status, foreign_key: "status_id"

  def self.new_record_state(person_id, state, change_reason='', user_id=nil)
    ActiveRecord::Base.transaction do
    user_id = User.current.id if user_id.blank?
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
    self.where(:person_id => person_id, :voided => 0).last.status.name rescue ""
  end

  def self.stats(types=['Normal', 'Adopted', 'Orphaned', 'Abandoned'], approved=true)
    result = {}
    birth_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

    Status.all.each do |status|
      result[status.name] = self.find_by_sql("
      SELECT COUNT(*) c FROM person_record_statuses s
        INNER JOIN person_birth_details p ON p.person_id = s.person_id
          AND p.birth_registration_type_id IN (#{birth_type_ids.join(', ')})
        WHERE voided = 0 AND status_id = #{status.id}")[0]['c']
    end

    unless approved == false
      excluded_states = ['HQ-REJECTED', 'HQ-VOIDED', 'HQ-PRINTED', 'HQ-DISPATCHED'].collect{|s| Status.find_by_name(s).id}
      included_states = Status.where("name like 'HQ-%' ").map(&:status_id)

      result['APPROVED BY ADR'] =  self.find_by_sql("
        SELECT COUNT(*) c FROM person_record_statuses s
        WHERE voided = 0 AND status_id NOT IN (#{excluded_states.join(', ')})
          AND status_id IN (#{included_states.join(', ')})")[0]['c']
    end
    result
  end

  def self.trace_data(person_id)
    return [] if person_id.blank?
    result = []
    PersonRecordStatus.where(person_id: person_id).order("created_at DESC").each do |status|
      user = User.find(status.creator)

      result << {
          "date" => status.created_at.strftime("%d-%b-%Y"),
          "time" => status.created_at.strftime("%I:%M %p"),
          "site" => user.user_role.role.level,
          "action" => "Status changed to:  '#{status.status.name.titleize.gsub(/^Hq/, "HQ").gsub(/^Dc/, 'DC').gsub(/^Fc/, 'FC')}'",
          "user"   => "#{user.first_name} #{user.last_name} <br /> <span style='font-size: 0.8em;'><i>(#{user.user_role.role.role})</i></span>",
          "comment" => status.comments
      }
    end

    result
  end
end
