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
        if params[:biological_parents] == "Both" || params[:biological_parents] =="Mother"
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
          ORDER BY p.updated_at DESC
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
            name_query += " AND  n.last_name = '#{filters[k]["person[last_name]"]}'"
          end
          if filters[k]["person[middle_name]"].present?
            name_query += " AND n.middle_name = '#{filters[k]["person[middle_name]"]}'"
          end
          if filters[k]["person[first_name]"].present?
            name_query += " AND n.first_name = '#{filters[k]["person[first_name]"]}'"
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

    main =   Person.order(" person.updated_at DESC ")
    main = main.joins(" INNER JOIN core_person cp ON person.person_id = cp.person_id
            INNER JOIN person_name n ON person.person_id = n.person_id
            INNER JOIN person_record_statuses prs ON person.person_id = prs.person_id
            INNER JOIN person_birth_details pbd ON person.person_id = pbd.person_id
            #{old_ben_identifier_join} ")

    main = main.where(" COALESCE(prs.voided, 0) = 0
            AND pbd.birth_registration_type_id IN (#{person_reg_type_ids.join(', ')}) AND n.voided = 0
            #{entry_num_query} #{fac_serial_query} #{name_query} #{gender_query} #{place_of_birth_query} #{status_query}
           AND concat_ws('_', pbd.national_serial_number, pbd.district_id_number, n.first_name, n.last_name, n.middle_name,
                person.birthdate, person.gender) REGEXP '#{search_val}' ")

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


  def self.create_nris_person(nris_person)
    
      # create core_person  
        core_person = CorePerson.create(
          :person_type_id     => PersonType.where(name: 'Client').last.id,
      )
      
      ebrs_person = core_person
      #create person
      person = Person.create(
          :person_id          => core_person.id,
          :gender             => nris_person[:sex] == 1 ? 'M' : 'F',
          :birthdate          => nris_person[:DateOfBirthString].to_date.to_s
       )
      #create person_name
      PersonName.create(
          :person_id          => core_person.id,
          :first_name         => nris_person[:FirstName],
          :middle_name        => nris_person[:OtherNames],
          :last_name          => nris_person[:Surname]
      )
      #create person_birth_detail 
      PersonBirthDetail.create(
        person_id: core_person.id,
        birth_registration_type_id: "",
        place_of_birth:  "",
        birth_location_id: nris_person[:PlaceOfBirthVillageId],
        district_of_birth:  nris_person[:PlaceOfBirthDistrictId],
        location_created_at: "" 
    )
    #create person identifier
      PersonIdentifier.create(
        person_id: father_person.person_id,
        person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
        value: nris_person[:BirthCertificateNumber].upcase
     )
     
     PersonIdentifier.create(
      person_id: core_person.id,
      person_identifier_type_id: (PersonIdentifierType.find_by_name("NRIS ID").id),
      value: nris_person[:NrisPk].upcase
    )

        #create_mother
        #create mother_core_person
          core_person = CorePerson.create(
            :person_type_id     => PersonType.where(name: 'Mother').last.id,
        )
        
        #create mother_person
        mother_person = Person.create(
            :person_id          => core_person.id,
            :gender             => 'F',
            :birthdate          =>  nris_person[:MotherBirthdate],
            :birthdate_estimated => nris_person[:MotherBirthdateEstimated]
        )
        #create mother_name
        PersonName.create(
            :person_id          => core_person.id,
            :first_name         => nris_person[:MotherFirstName],
            :middle_name        => nris_person[:MotherMaidenName],
            :last_name          => nris_person[:MotherLastName]
        )
        #create mother_address
        PersonAddress.create(
            :person_id          => core_person.id,
            :current_district   => "",
            :current_ta         => "",
            :current_village    => "",
            :home_district   => nris_person[:MotherDistrictId],
            :home_ta            => "",
            :home_village       => nris_person[:MotherVillageId],
            :citizenship        => Location.where(country: nris_person[:MotherNationality]).last.id,
            
        )
        #create mother_identifier
        if nris_person[:MotherPin].present?
    
          PersonIdentifier.create(
                    person_id: mother_person.person_id,
                    person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
                    value: nris_person[:MotherPin].upcase
            )
        end
    
        # create mother_relationship
        PersonRelationship.create(
            person_a: ebrs_person.id, person_b: core_person.id,
            person_relationship_type_id: PersonRelationType.where(name: 'Mother').last.id
        )
        
      #create_father
      #create father_core_person
      if nris_person[:FatherFirstName].present? && nris_person[:FatherSurname].present?
        core_person = CorePerson.create(
          :person_type_id     => PersonType.where(name: 'Father').last.id,
      )
      
      #create father_person
      father_person = Person.create(
          :person_id          => core_person.id,
          :gender             => 'M',
          :birthdate          =>  nris_person[:FatherBirthdate],
          :birthdate_estimated => nris_person[:FatherBirthdateEstimated]
      )
      #create father_name
      PersonName.create(
          :person_id          => core_person.id,
          :first_name         => nris_person[:FatherFirstName],
          :middle_name        => nris_person[:FatherOtherNames],
          :last_name          => nris_person[:FatherSurname]
      )
      #create father_address
      PersonAddress.create(
          :person_id          => core_person.id,
          :current_district   => "",
          :current_ta         => "",
          :current_village    => "",
          :home_district  => nris_person[:FatherDistrictId],
          :home_ta => "",
          :home_village => nris_person[:FatherVillageId],
          :citizenship => Location.where(country: nris_person[:FatherNationality]).last.id,
          
      )
      
      #create father_identifier
      if nris_person[:FatherPin].present?
    
        PersonIdentifier.create(
                  person_id: father_person.person_id,
                  person_identifier_type_id: (PersonIdentifierType.find_by_name("National ID Number").id),
                  value: nris_person[:FatherPin].upcase
          )
      end
    
       # create father_relationship
       PersonRelationship.create(
        person_a: ebrs_person.id, person_b: core_person.id,
        person_relationship_type_id: PersonRelationType.where(name: 'Father').last.id
      )
    
      end
      return ebrs_person.id
    end

end
