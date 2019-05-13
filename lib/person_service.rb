module PersonService
  require 'bean'
  require 'json'

  def self.create_record(params)

    registration_type   = params[:person][:relationship]
    person  = Lib.new_child(params)
    case registration_type
      when "normal"
        mother   = Lib.new_mother(person, params, 'Mother')
        father   = Lib.new_father(person, params,'Father')
        informant = Lib.new_informant(person, params)
      when "orphaned"
        #mother   = Lib.new_mother(person, params, 'Adoptive-Mother')
        #father   = Lib.new_father(person, params,'Adoptive-Father')
        informant = Lib.new_informant(person, params)
      when "adopted"
        if params[:biological_parents] == "Both" || params[:biological_parents] =="Mother"
          mother   = Lib.new_mother(person, params, 'Mother')
        end
        if params[:biological_parents] == "Both" || params[:biological_parents] =="Father"
          father   = Lib.new_father(person, params,'Father')
        end
        if params[:foster_parents] == "Both" || params[:foster_parents] =="Mother"
          adoptive_mother   = Lib.new_mother(person, params, 'Adoptive-Mother')
        end
        if params[:foster_parents] == "Both" || params[:foster_parents] =="Father"
          adoptive_father   = Lib.new_father(person, params,'Adoptive-Father')
        end
        informant = Lib.new_informant(person, params)
      when "abandoned"
        if params[:parents_details_available] == "Both" || params[:parents_details_available] == "Mother"
          mother   = Lib.new_mother(person, params, 'Mother')
        end
        if params[:parents_details_available] == "Both" || params[:parents_details_available] == "Father"
          mother   = Lib.new_father(person, params, 'Father')
        end
        informant = Lib.new_informant(person, params)
    else 

    end

    details = Lib.new_birth_details(person, params)
    status = Lib.workflow_init(person,params)
    return person
  end

  def self.update_record(params)

  end  

  def self.is_num?(val)

    #checks if the val is numeric or string
      !!Integer(val)
    rescue ArgumentError, TypeError
      false

  end

  def self.mother(person_id)
    birth_details = PersonBirthDetail.where(person_id: person_id).first
    birth_registration_type_id = birth_details.birth_registration_type_id
    registration_name = BirthRegistrationType.where(birth_registration_type_id: birth_registration_type_id).last.name
    case registration_name
    when "Adopted"
         relationship_name = "Adoptive-Mother"  
    else
        relationship_name = "Mother"   
    end

    result = nil
    relationship_type = PersonRelationType.find_by_name(relationship_name)

    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last

    unless relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.father(person_id)
    birth_details = PersonBirthDetail.where(person_id: person_id).first
    birth_registration_type_id = birth_details.birth_registration_type_id
    registration_name = BirthRegistrationType.where(birth_registration_type_id: birth_registration_type_id).last.name
    case registration_name
    when "Adopted"
         relationship_name = "Adoptive-Father"  
    else
        relationship_name = "Father"   
    end

    result = nil
    relationship_type = PersonRelationType.find_by_name(relationship_name)

    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last

    unless relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.informant(person_id)
    birth_details = PersonBirthDetail.where(person_id: person_id).first

    relationship_name = "Informant"
    result = nil
    relationship_type = PersonRelationType.find_by_name(relationship_name)

    relationship = PersonRelationship.where(:person_a => person_id, :person_relationship_type_id => relationship_type.id).last

    unless relationship.blank?
      result = PersonName.where(:person_id => relationship.person_b).last
    end

    result
  end

  def self.query_for_display(states, types=['Normal', 'Abandoned', 'Adopted', 'Orphaned'])

    state_ids = states.collect{|s| Status.find_by_name(s).id} + [-1]

    person_reg_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

    main = Person.find_by_sql(
        "SELECT n.*, prs.status_id, pbd.district_id_number AS ben, pbd.national_serial_number AS brn FROM person p
            INNER JOIN core_person cp ON p.person_id = cp.person_id
            INNER JOIN person_name n ON p.person_id = n.person_id
            INNER JOIN person_record_statuses prs ON p.person_id = prs.person_id AND COALESCE(prs.voided, 0) = 0
            INNER JOIN person_birth_details pbd ON p.person_id = pbd.person_id
          WHERE prs.status_id IN (#{state_ids.join(', ')}) AND n.voided = 0
            AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')})
          GROUP BY prs.person_id
          ORDER BY pbd.district_id_number, p.updated_at
           "
    )

    results = []

    main.each do |data|
      person_name =  Person.find(data.person_id).person_names.last
      mother = self.mother(data.person_id)
      father = self.father(data.person_id)
      #For abandoned cases mother details may not be availabe
      #next if mother.blank?
      #next if mother.first_name.blank?
      #The form treat Father as optional
      #next if father.blank?
      #next if father.first_name.blank?
      name          = ("#{person_name.first_name} #{person_name.middle_name rescue ''} #{person_name.last_name}")
      mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
      father_name   = ("#{father.first_name rescue 'N/A'} #{father.middle_name rescue ''} #{father.last_name rescue ''}")

      results << {
          'id' => data.person_id,
          'ben' => data.ben,
          'brn' => data.brn,
          'name'        => name,
          'father_name'       => father_name,
          'mother_name'       => mother_name,
          'status'            => Status.find(data.status_id).name, #.gsub(/DC\-|FC\-|HQ\-/, '')
          'date_of_reporting' => data['created_at'].to_date.strftime("%d/%b/%Y"),
      }
    end

    results

  end

  def self.search_results(filters={}, params)

    if filters.blank?
      return []
    end
    entry_num_query = ''; fac_serial_query = ''; name_query = ''; limit = ' '
    limit = ' LIMIT 10 ' if filters.blank?
    gender_query = ''; place_of_birth_query = ''; status_query=''

    types = []
    if params[:type] == 'All'
      types=['Normal', 'Abandoned', 'Adopted', 'Orphaned']
    else
      types=[params[:type]]
    end

    person_reg_type_ids = BirthRegistrationType.where(" name IN ('#{types.join("', '")}')").map(&:birth_registration_type_id) + [-1]

    old_ben_identifier_join = " "
    old_ben_type_id = PersonIdentifierType.where(name: "Old Birth Entry Number").first.id

    faulty_ids = [-1] + PersonRecordStatus.find_by_sql("SELECT prs.person_record_status_id FROM person_record_statuses prs
                                                LEFT JOIN person_record_statuses prs2 ON prs.person_id = prs2.person_id AND prs.voided = 0 AND prs2.voided = 0
                                                WHERE prs.created_at < prs2.created_at;").map(&:person_record_status_id)

    filters.keys.each do |k|
      case k
        when 'Birth Entry Number'

          legacy = PersonIdentifier.where(value: filters[k]['person[birth_entry_number]'], person_identifier_type_id: old_ben_type_id)
          legacy_available = legacy.length > 0
          if legacy_available
            old_ben_identifier_join = " INNER JOIN person_identifiers pid2 ON pid2.person_id = cp.person_id AND pid2.value = '#{filters[k]['person[birth_entry_number]']}' "
          else
            entry_num_query = " AND pbd.district_id_number = '#{filters[k]['person[birth_entry_number]']}' "
          end
        when 'Facility Serial Number'
          fac_serial_query =  " AND pbd.facility_serial_number = '#{filters[k]['person[facility_serial_number]']}' "
        when 'Child Name'
          if filters[k]["person[last_name]"].present?
            name_query += " AND  n.last_name = \"#{filters[k]["person[last_name]"]}\" "
          end
          if filters[k]["person[middle_name]"].present?
            name_query += " AND n.middle_name = \"#{filters[k]["person[middle_name]"]}\" "
          end
          if filters[k]["person[first_name]"].present?
            name_query += " AND n.first_name = \"#{filters[k]["person[first_name]"]}\" "
          end
        when 'Child Gender'
          gender_query = " AND person.gender = '#{filters[k]["person[gender]"].split('')[0]}' "
        when 'Place of Birth'
          place_id = Location.locate_id_by_tag(filters[k]["person[place_of_birth]"], 'Place of Birth')
          if place_id.present?
            place_of_birth_query = " AND  place_of_birth = #{place_id} "
          end
          district_id = Location.locate_id_by_tag(filters[k]["person[birth_district]"], 'District')
          if district_id.present?
            place_of_birth_query += " AND  district_of_birth = #{district_id} "
          end
          ta_id = Location.locate_id(filters[k]["person[birth_ta]"], 'Traditional Authority', district_id)
          if ta_id.present?
            village_id = Location.locate_id(filters[k]["person[birth_village]"], 'Village', ta_id)
            place_of_birth_query += " AND  birth_location_id = #{village_id} "
          end

          hospital_id = Location.locate_id(filters[k]["person[hospital_of_birth]"], 'Health Facility', district_id)
          if hospital_id.present?
            place_of_birth_query += " AND  birth_location_id = #{hospital_id} "
          end

          if filters[k]["other_birth_place"].present?
            place_of_birth_query += " AND  other_birth_location = '#{filters[k]["other_birth_place"].strip}' "
          end
        when 'Record Status'
          status_id = Status.where(name: filters[k]["person[record_status]"]).last.id
          status_query = " AND prs.status_id = #{status_id} "
      end
    end

    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?

    main =   Person.order(" person.created_at DESC ")
    main = main.joins(" INNER JOIN core_person cp ON person.person_id = cp.person_id
            INNER JOIN person_name n ON person.person_id = n.person_id
            INNER JOIN person_record_statuses prs ON person.person_id = prs.person_id
            INNER JOIN person_birth_details pbd ON person.person_id = pbd.person_id
            #{old_ben_identifier_join} ")

    main = main.where(" COALESCE(prs.voided, 0) = 0
            AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')}) AND n.voided = 0
            AND prs.person_record_status_id NOT IN (#{faulty_ids.join(', ')})
            #{entry_num_query} #{fac_serial_query} #{name_query} #{gender_query} #{place_of_birth_query} #{status_query}
           AND concat_ws('_', pbd.national_serial_number, pbd.district_id_number, n.first_name, n.last_name, n.middle_name,
                person.birthdate, person.gender) REGEXP \"#{search_val}\" ")

    total = main.select(" count(*) c ")[0]['c'] rescue 0
    page = (params[:start].to_i / params[:length].to_i) + 1

    data = main.group(" prs.person_id ")

    data = data.select(" n.*, prs.status_id, pbd.district_id_number AS ben, person.gender, person.birthdate, pbd.national_serial_number AS brn, pbd.date_reported")
    data = data.page(page)
    .per_page(params[:length].to_i)

    @records = []
    data.each do |p|
      mother = PersonService.mother(p.person_id)
      father = PersonService.father(p.person_id)
      details = PersonBirthDetail.find_by_person_id(p.person_id)

      name          = ("#{p['first_name']} #{p['middle_name']} #{p['last_name']}")
      mother_name   = ("#{mother.first_name rescue 'N/A'} #{mother.middle_name rescue ''} #{mother.last_name rescue ''}")
      father_name   = ("#{father.first_name rescue 'N/A'} #{father.middle_name rescue ''} #{father.last_name rescue ''}")
      row = []
      row = [p.ben] if params[:assign_ben] == 'true'
      row = row + [
          "#{name} (#{p.gender})",
          p.birthdate.strftime('%d/%b/%Y'),
          mother_name,
          father_name,
          p.date_reported.strftime('%d/%b/%Y'),
          Status.find(p.status_id).name,
          p.person_id
      ]
      @records << row
    end

    {
        "draw" => params[:draw].to_i,
        "recordsTotal" => total,
        "recordsFiltered" => total,
        "data" => @records}
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

	def self.get_identifier(person_id, type)
		type_id = PersonIdentifierType.where(name: type).first
		return nil if type_id.blank? 

		identifier = PersonIdentifier.where(
			person_id: person_id, 
			person_identifier_type_id: type_id		
		).first

		return nil if identifier.blank?
		identifier.value
	end

  def self.create_mass_registration_person(mass_reg_person, status)

    user_id = User.where(username: "admin#{SETTINGS['location_id']}").last.id
    codes = JSON.parse(File.read("#{Rails.root}/db/code2country.json"))

    # create core_person
    core_person = CorePerson.create(
        :person_type_id     => PersonType.where(name: 'Client').last.id,
    )

    ebrs_person = core_person
    #create person

    person = Person.create(
        :person_id          => core_person.id,
        :gender             => mass_reg_person[:gender].upcase.first == "M" ? 'M' : 'F',
        :birthdate          => mass_reg_person[:date_of_birth].to_date.to_s
    )

    #create person_name
    PersonName.create(
        :person_id          => core_person.id,
        :first_name         => mass_reg_person[:first_name],
        :middle_name        => mass_reg_person[:middle_name],
        :last_name          => mass_reg_person[:last_name]
    )

    #create person_birth_detail
    other_place = nil
    district_id = Location.locate_id_by_tag(mass_reg_person["district_of_birth"], "District")
    ta_id = Location.locate_id(mass_reg_person["ta_of_birth"], "Traditional Authority", district_id)
    village_id = Location.locate_id(mass_reg_person["village_of_birth"], "Village", ta_id)
    reg_type = BirthRegistrationType.where(name: "Normal").last.id

    if village_id.blank?
      other_place = mass_reg_person["village_of_birth"]
      village_id = Location.locate_id_by_tag("Other", "Place Of Birth")
    end


    details = PersonBirthDetail.create(
        person_id: core_person.id,
        birth_registration_type_id: reg_type,
        place_of_birth:  Location.locate_id_by_tag("Home", "Place Of Birth"),
        birth_location_id: village_id,
        district_of_birth:  district_id,
        other_birth_location: other_place,
        type_of_birth: PersonTypeOfBirth.where(name: "Unknown").last.id,
        mode_of_delivery_id: ModeOfDelivery.where(name: "Unknown").last.id,
        location_created_at: Location.locate_id_by_tag(mass_reg_person["location_created_at"], "Village"),
        acknowledgement_of_receipt_date: mass_reg_person["created_at"].to_date.to_s,
        date_reported: mass_reg_person["created_at"].to_date.to_s,
        date_registered: mass_reg_person["created_at"].to_date.to_s,
        level_of_education_id: LevelOfEducation.where(name: "Unknown").last.id,
        informant_relationship_to_person: mass_reg_person[:informant_relationship],
        form_signed: (mass_reg_person[:form_signed] == "Yes" ? 1 : 0),
        flagged: 1,
        creator: user_id,
        source_id: (-1 * mass_reg_person['id'].to_i).to_s + "#" + mass_reg_person["creator"]
    )

    #create_mother
    #create mother_core_person
    exi_mother = PersonIdentifier.where(value: mass_reg_person[:mother_id_number], voided: 0).first

    if !exi_mother.blank?
      core_person = CorePerson.where(person_id: exi_mother.person_id).first
      mother_person = Person.where(person_id: exi_mother.person_id).first

      File.open("#{Rails.root}/existing_ids", "a"){|f|
        f.write(mass_reg_person[:mother_id_number])
      }
    else

      core_person = CorePerson.create(
          :person_type_id     => PersonType.where(name: 'Mother').last.id,
      )

      #create mother_person
      mother_person = Person.create(
          :person_id          => core_person.id,
          :gender             => 'F',
          :birthdate          =>  "1900-01-01",
          :birthdate_estimated => true
      )
      #create mother_name
      PersonName.create(
          :person_id          => core_person.id,
          :first_name         => mass_reg_person[:mother_first_name],
          :middle_name        => mass_reg_person[:mother_middle_name],
          :last_name          => mass_reg_person[:mother_last_name]
      )
      #create mother_address
      m_district_id = nil #Location.locate_id_by_tag(mass_reg_person["MotherDistrictName"], "District")
      m_ta_id = nil #Location.locate_id(mass_reg_person["MotherTAName"], "Traditional Authority", district_id)
      m_village_id = nil #Location.locate_id(mass_reg_person["MotherVillageName"], "Village", ta_id)
      m_citizenship = Location.where(country: mass_reg_person[:mother_nationality]).last.id
      m_citizenship = Location.where(name: "Other").first.id if m_citizenship.blank?

      pam = PersonAddress.new(
          :person_id          => core_person.id,
          :home_district   => m_district_id,
          :home_ta            => m_ta_id,
          :home_village       => m_village_id,
          :citizenship        => m_citizenship,
          :residential_country => m_citizenship
      )

      #pam.home_district_other = mass_reg_person["MotherDistrictName"] if m_district_id.blank?
      #pam.home_ta_other = mass_reg_person["MotherTAName"] if m_ta_id.blank?
      #pam.home_village_other = mass_reg_person["MotherVillageName"] if m_village_id.blank?
      pam.save

      #create mother_identifier
      if mass_reg_person[:mother_id_number].present?

        PersonIdentifier.create(
            person_id: mother_person.person_id,
            person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
            value: mass_reg_person[:mother_id_number].upcase.strip
        )
      end
    end
    # create mother_relationship
    PersonRelationship.create(
        person_a: ebrs_person.id, person_b: core_person.id,
        person_relationship_type_id: PersonRelationType.where(name: 'Mother').last.id
    )

    #create_father
    if mass_reg_person[:father_first_name].present? && mass_reg_person[:father_last_name].present?

      exi_father = PersonIdentifier.where(value: mass_reg_person[:father_id_number], voided: 0).first

      if !exi_father.blank?
        core_person = CorePerson.where(person_id: exi_father.person_id).first
        father_person = Person.where(person_id: exi_father.person_id).first
      else

        core_person = CorePerson.create(
            :person_type_id     => PersonType.where(name: 'Father').last.id,
        )

        #create father_person
        father_person = Person.create(
            :person_id          => core_person.id,
            :gender             => 'M',
            :birthdate          =>  "1900-01-01".to_date.to_s,
            :birthdate_estimated => true
        )
        #create father_name
        PersonName.create(
            :person_id          => core_person.id,
            :first_name         => mass_reg_person[:father_first_name],
            :middle_name        => mass_reg_person[:father_middle_name],
            :last_name          => mass_reg_person[:father_last_name]
        )

        #create father_address
        f_district_id = nil #Location.locate_id_by_tag(mass_reg_person["FatherDistrictName"], "District")
        f_ta_id = nil #Location.locate_id(mass_reg_person["FatherTAName"], "Traditional Authority", district_id)
        f_village_id = nil #Location.locate_id(mass_reg_person["FatherVillageName"], "Village", ta_id)
        f_citizenship = Location.where(country: mass_reg_person[:father_nationality]).last.id
        f_citizenship = Location.where(name: "Other").first.id if f_citizenship.blank?

        paf = PersonAddress.new(
            :person_id          => core_person.id,
            :home_district  => f_district_id,
            :home_ta => f_ta_id,
            :home_village => f_village_id,
            :citizenship => f_citizenship,
            :residential_country => f_citizenship
        )

        #paf.home_district_other = mass_reg_person["FatherDistrictName"] if f_district_id.blank?
        #paf.home_ta_other = mass_reg_person["FatherTAName"]   if f_ta_id.blank?
        #paf.home_village_other = mass_reg_person["FatherVillageName"] if f_village_id.blank?
        paf.save

        #create father_identifier
        if mass_reg_person[:father_id_number].present?

          PersonIdentifier.create(
              person_id: father_person.person_id,
              person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
              value: mass_reg_person[:father_id_number].upcase.strip
          )
        end
      end

      # create father_relationship
      PersonRelationship.create(
          person_a: ebrs_person.id,
          person_b: core_person.id,
          person_relationship_type_id: PersonRelationType.where(name: 'Father').last.id
      )
    end

    exi_informant = PersonIdentifier.where(value: mass_reg_person[:informant_id_number], voided: 0).first

    if !exi_informant.blank?
      informant_person = CorePerson.where(person_id: exi_informant.person_id).first
    elsif mass_reg_person[:informant_relationship] == "Mother" && !mother_person.blank?
      informant_person = mother_person
    elsif mass_reg_person[:informant_relationship] == "Father" && !father_person.blank?
      informant_person = father_person
    else

      informant_person = CorePerson.create(
          :person_type_id     => PersonType.where(name: 'Informant').last.id,
      )

      #create informant_person
      informant_person = Person.create(
          :person_id          => informant_person.id,
          :gender             => 'N/A',
          :birthdate          =>  "1900-01-01".to_date.to_s,
          :birthdate_estimated => true
      )
      #create informant_name
      PersonName.create(
          :person_id          => informant_person.id,
          :first_name         => mass_reg_person[:informant_first_name],
          :middle_name        => mass_reg_person[:informant_middle_name],
          :last_name          => mass_reg_person[:informant_last_name]
      )

      #create informant identifier
      if mass_reg_person[:informant_id_number].present?
        PersonIdentifier.create(
            person_id: informant_person.person_id,
            person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
            value: mass_reg_person[:informant_id_number].upcase.strip
        )
      end
    end

    #create informant_address
    pai = PersonAddress.where(person_id: informant_person.person_id).first
    i_district_id = Location.locate_id_by_tag(mass_reg_person["informant_district"], "District")
    i_ta_id = Location.locate_id(mass_reg_person["informant_ta"], "Traditional Authority", district_id)
    i_village_id = Location.locate_id(mass_reg_person["informant_village"], "Village", ta_id)
    i_resident_country = Location.locate_id_by_tag(mass_reg_person[:informant_nationality], 'Country')
    i_resident_country = Location.where(name: "Other").first.id if i_resident_country.blank?

    pai = PersonAddress.new() if pai.blank?
    pai.person_id         = informant_person.person_id
    pai.current_district  = i_district_id
    pai.current_ta = i_ta_id
    pai.current_village = i_village_id
    pai.citizenship = i_resident_country
    pai.residential_country = i_resident_country
    pai.address_line_1 = mass_reg_person[:informant_address_line1]
    pai.address_line_2 = (mass_reg_person[:informant_address_line2].to_s + "  " + mass_reg_person[:informant_address_line3].to_s).strip

    pai.save


    PersonRelationship.create(
        person_a: ebrs_person.id,
        person_b: informant_person.id,
        person_relationship_type_id: PersonRelationType.where(name: 'Informant').last.id
    )


    if mass_reg_person[:informant_phone_number].present?
      PersonAttribute.create(
          :person_id                => informant_person.id,
          :person_attribute_type_id => PersonAttributeType.where(name: 'cell phone number').last.id,
          :value                    => mass_reg_person[:informant_phone_number],
          :voided                   => 0
      )
    end

    if mass_reg_person[:village_headman_name].present?
      PersonAttribute.create(
          :person_id                => details.person_id,
          :person_attribute_type_id => PersonAttributeType.where(name: 'Village Headman Name').last.id,
          :value                    => mass_reg_person[:village_headman_name],
          :voided                   => 0
      )
    end

    if mass_reg_person[:village_headman_signed].present?
      PersonAttribute.create(
          :person_id                => details.person_id,
          :person_attribute_type_id => PersonAttributeType.where(name: 'Village Headman Signature').last.id,
          :value                    => mass_reg_person[:village_headman_signed],
          :voided                   => 0
      )
    end

    PersonRecordStatus.new_record_state(ebrs_person.id, status, "NEW RECORD FROM COMMUNITY REGISTRATION")

=begin
    allocation = IdentifierAllocationQueue.new
    allocation.person_id = ebrs_person.id
    allocation.assigned = 0
    allocation.creator = User.current.id
    allocation.person_identifier_type_id = PersonIdentifierType.where(:name => "Birth Entry Number").last.person_identifier_type_id
    allocation.created_at = Time.now
    allocation.save
=end
    return ebrs_person.id
  end

  def self.exact_duplicates(params)

    mother_type = ""
    mother      = {}

    if params[:foster_parents] == "Both" || params[:foster_parents] =="Mother"
      mother_type  = 'Adoptive-Mother'
    end

    if mother_type =="Adoptive-Mother"
      mother = params[:person][:foster_mother]
    else
      mother = params[:person][:mother]
    end

    mother_relationship_ids = PersonRelationType.where(" name IN ('Mother', 'Adoptive-Mother') ").collect{|r| r.id}

    #Query by name
    person_ids = PersonName.find_by_sql(" SELECT pn.person_id FROM person_name pn
      INNER JOIN person_birth_details pbd On pbd.person_id = pn.person_id AND pn.voided = 0
      AND pn.first_name = '#{params[:person][:first_name]}' AND pn.last_name = '#{params[:person][:last_name]}'
    ").map(&:person_id)

    return [] if person_ids.blank?

    #Query by gender and birthdate
    gender = {'Female' => 'F', 'Male' => 'M'}[params[:person][:gender]]
    person_ids = Person.find_by_sql(" SELECT person_id FROM person
                  WHERE person_id IN (#{person_ids.join(',')}) AND gender ='#{gender}'
                  AND birthdate = '#{params[:person][:birthdate].to_date.to_s}' ").collect{|p| p.person_id}

    return [] if person_ids.blank?

    person_ids = PersonName.find_by_sql(
        "SELECT pr.person_a FROM person_name pn INNER JOIN person_relationship pr ON pr.person_b = pn.person_id
          AND pn.voided = 0 AND pr.person_relationship_type_id IN (#{mother_relationship_ids.join(',')})
          AND pn.first_name = '#{mother[:first_name]}' AND pn.last_name = '#{mother[:last_name]}' AND pr.person_a IN (#{person_ids.join(',')})"
    ).collect{|p| p.person_a}

    return [] if person_ids.blank?

    if !mother['home_district'].blank?
      person_ids = PersonAddress.find_by_sql(
          "SELECT pr.person_a FROM person_addresses pa
            INNER JOIN person_relationship pr ON pr.person_b = pa.person_id
            INNER JOIN location l ON l.location_id = pa.home_district
              AND pr.person_relationship_type_id IN (#{mother_relationship_ids.join(',')})
              AND l.name = '#{mother['home_district']}'
              AND pa.home_district AND pr.person_a IN (#{person_ids.join(',')})"
      ).collect{|p| p.person_a}
    end

    return [] if person_ids.blank?

    #Query by place of birth
    map =  {'Mzuzu City' => 'Mzimba',
            'Lilongwe City' => 'Lilongwe',
            'Zomba City' => 'Zomba',
            'Blantyre City' => 'Blantyre'}

    params[:person][:birth_district] = map[params[:person][:birth_district]] if params[:person][:birth_district].match(/City$/)
    district_id = Location.locate_id_by_tag(params[:person][:birth_district], 'District')

    person_ids = PersonBirthDetail.find_by_sql("
      SELECT person_id FROM person_birth_details pbd
        WHERE district_of_birth = #{district_id} AND person_id IN (#{person_ids.join(',')})
    ").collect{|p| p.person_id}

    return person_ids
  end


  def self.qr_code_data(person_id)
    person = Person.find(person_id)
    details = PersonBirthDetail.where(person_id: person_id).first

    birth_district = Location.find(details.district_of_birth).name rescue nil
    place_of_birth = Location.find(details.birth_location_id).name rescue details.other_place_of_birth

    if place_of_birth.downcase == 'other'
      place_of_birth = details.other_birth_location
    end
    if !place_of_birth.blank?
      place_of_birth += ", " + birth_district
    else
      place_of_birth = birth_district
    end

    str = "04~#{person.id_number}-#{details.district_id_number}-#{details.brn}"
    str += "~#{person.printable_name}~#{person.birthdate.to_date.strftime("%d-%b-%Y")}~#{person.gender}"
    str += "~#{place_of_birth}"
    str += ("~#{person.mother.printable_name}" rescue '~')
    str += ("~#{person.mother.citizenship}" rescue '~')
    str += ("~#{person.father.printable_name}" rescue '~')
    str += ("~#{person.father.citizenship}" rescue '~')
    str += ("~#{details.date_registered.to_date.strftime("%d-%b-%Y")}" rescue nil)

    str
  end

  def self.request_nris_id_remote(person_id)
    remote_url = "#{SETTINGS["destination_app_link"]}/person_id/remote_nid_request?person_id=#{person_id}"
    results = RestClient.get(remote_url) rescue "REMOTE SERVER COULD NOT BE REACHED"
    results
  end

end
