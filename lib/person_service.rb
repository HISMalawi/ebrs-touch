module PersonService
  require 'bean'
  require 'json'

  def self.create_record(params)
    #raise params[:person].inspect
    registration_type   = params[:relationship]
    person  = Lib.new_child(params)

    case registration_type
    when "normal"       
       mother   = Lib.new_mother(person, params, 'Mother')
       father   = Lib.new_father(person, params,'Father')
       informant = Lib.new_informant(person, params)
    when "orphaned"
       mother   = Lib.new_mother(person, params, 'Adoptive-Mother')
       father   = Lib.new_father(person, params,'Adoptive-Father')
       informant = Lib.new_informant(person, params)
    when "adopted"
       mother   = Lib.new_mother(person, params, 'Adoptive-Mother')
       father   = Lib.new_father(person, params,'Adoptive-Father')
       informant = Lib.new_informant(person, params)
    else 

    end
    details = Lib.new_birth_details(person, params)
    status = Lib.workflow_init(person,params)
    return person;
  end

  def self.is_num?(val)

    #checks if the val is numeric or string
      !!Integer(val)
    rescue ArgumentError, TypeError
      false

  end

  def self.mother(person_id)
    result = nil
    #raise person_id.inspect
    relationship_type = PersonRelationType.find_by_name("Mother")

   # raise relationship_type.id.inspect

    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last
    #raise relationship.person_b.inspect
    unless relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.father(person_id)
    result = nil
    relationship_type = PersonRelationType.find_by_name("Father")
    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last
    if !relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.query_for_display(states)

    state_ids = states.collect{|s| Status.find_by_name(s).id} + [-1]

    person_type = PersonType.where(name: 'Client').first


    main = Person.find_by_sql(
          "SELECT n.*, prs.status_id FROM person p
            INNER JOIN core_person cp ON p.person_id = cp.person_id
            INNER JOIN person_name n ON p.person_id = n.person_id
            INNER JOIN person_record_statuses prs ON p.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
            INNER JOIN person_birth_details pbd ON p.person_id = pbd.person_id
          WHERE prs.status_id IN (#{state_ids.join(', ')})
            AND cp.person_type_id = #{person_type.id}
          GROUP BY p.person_id
          ORDER BY p.updated_at DESC
           "
    )


    results = []

    main.each do |data|
      mother = self.mother(data.person_id)
      father = self.father(data.person_id)
      next if mother.blank?
      next if mother.first_name.blank?
      #The form treat Father as optional
      #next if father.blank?
      #next if father.first_name.blank?
      name          = ("#{data['first_name']} #{data['middle_name']} #{data['last_name']}")
      mother_name   = ("#{mother.first_name} #{mother.middle_name} #{mother.last_name}")
      father_name   = ("#{father.first_name rescue ''} #{father.middle_name rescue ''} #{father.last_name rescue ''}")

      results << {
          'id' => data.person_id,
          'name'        => name,
          'father_name'       => father_name,
          'mother_name'       => mother_name,
          'status'            => Status.find(data.status_id).name, #.gsub(/DC\-|FC\-|HQ\-/, '')
          'date_of_reporting' => data['created_at'].to_date.strftime("%d/%b/%Y"),
      }
    end

    results

  end

  def self.record_complete?(child)
      name = PersonName.find_by_person_id(child.id)
      pbs = PersonBirthDetail.find_by_person_id(child.id) rescue nil
      birth_type = BirthRegistrationType.find(pbs.birth_registration_type_id).name rescue nil
      mother_name = self.mother(child.id)
      father_name = self.father(child.id)
      complete = false

      return false if pbs.blank?

      if name.first_name.blank?
        return complete
      end

      if name.last_name.blank?
        return complete
      end

      if (child.birthdate.to_date.blank? rescue true)
          return complete
      end

      if child.gender.blank? || child.gender == 'N/A'
        return complete
      end

      if birth_type.downcase == "normal"

        if mother_name.first_name.blank?
          return complete
        end

        if mother_name.last_name.blank?
          return complete
        end

      end

      if pbs.parents_married_to_each_other.to_s == '1'
        if father_name.first_name.blank?
          return complete
        end

        if father_name.last_name.blank?
          return complete
        end
      end

      return true

  end

end
