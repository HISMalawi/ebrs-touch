puts "Init Couchdb (indexing) ...."
PersonTypeOfBirthsCouchdb.count
StatusCouchdb.count
PersonRelationshipTypesCouchdb.count
PersonAttributeTypesCouchdb.count
ModeOfDeliveryCouchdb.count
LocationTagMapCouchdb.count
LocationCouchdb.count
LocationTagCouchdb.count
LevelOfEducationCouchdb.count
BirthRegistrationTypeCouchdb.count
PersonTypeCouchdb.count
RoleCouchdb.count
puts "Init Couchdb (indexing) done ...."

=begin
birth_registration_types = BirthRegistrationType.all
birth_registration_types.each do |birth_registration_type|
    birth_registration_type_couchdb = BirthRegistrationTypeCouchdb.new
    birth_registration_type_couchdb.birth_registration_type_id = birth_registration_type.birth_registration_type_id
    birth_registration_type_couchdb.name = birth_registration_type.name
    birth_registration_type_couchdb.save
end
=end
birth_registration_type_couchdbs = BirthRegistrationTypeCouchdb.all
birth_registration_type_couchdbs.each do |birth_registration_type_couchdb|
  birth_registration_type = BirthRegistrationType.create(
    birth_registration_type_id: birth_registration_type_couchdb.birth_registration_type_id,
    name:                       birth_registration_type_couchdb.name
  )
  puts "Loading BirthRegistrationType: #{birth_registration_type.name}"
end



=begin
education_levels = LevelOfEducation.all
education_levels.each do |education_level|
  level_of_education_couchdb = LevelOfEducationCouchdb.new
  level_of_education_couchdb.level_of_education_id = education_level.level_of_education_id
  level_of_education_couchdb.name = education_level.name
  level_of_education_couchdb.save
end
=end
level_of_education_couchdbs = LevelOfEducationCouchdb.all
level_of_education_couchdbs.each do |level_of_education_couchdb|
  education_level = LevelOfEducation.create(
    level_of_education_id: level_of_education_couchdb.level_of_education_id,
    name:                  level_of_education_couchdb.name
  )
  puts "Loading LevelOfEducation: #{education_level.name}"
end

=begin
location_tags = LocationTag.all
location_tags.each do |location_tag|
  location_tag_couch_db = LocationTagCouchdb.new
  location_tag_couch_db.location_tag_id = location_tag.location_tag_id
  location_tag_couch_db.name = location_tag.name
  location_tag_couch_db.description = location_tag.description
  location_tag_couch_db.save
end
=end
location_tag_couch_dbs = LocationTagCouchdb.all
location_tag_couch_dbs.each do |location_tag_couch_db|
  location_tag = LocationTag.create(
    location_tag_id:  location_tag_couch_db.location_tag_id,
    name:             location_tag_couch_db.name,
    description:      location_tag_couch_db.description
  )
  puts "Loading LocationTag: #{location_tag.name}"
end

=begin
locations = Location.all
locations.each do |location|
  location_couchdb = LocationCouchdb.new
  location_couchdb.location_id = location.location_id
  location_couchdb.code = location.code
  location_couchdb.name = location.name
  location_couchdb.description = location.description
  location_couchdb.postal_code = location.postal_code
  location_couchdb.country = location.country
  location_couchdb.latitude = location.latitude
  location_couchdb.longitude = location.longitude
  location_couchdb.county_district = location.county_district
  location_couchdb.creator = location.creator
  location_couchdb.changed_by = location.changed_by
  location_couchdb.changed_at = location.changed_at
  location_couchdb.save
end
=end
location_couchdbs = LocationCouchdb.all
location_couchdbs.each do |location_couchdb|
  location = Location.create(
    location_id:      location_couchdb.location_id,
    code:             location_couchdb.code,
    name:             location_couchdb.name,
    description:      location_couchdb.description,
    postal_code:      location_couchdb.postal_code,
    country:          location_couchdb.country,
    latitude:         location_couchdb.latitude,
    longitude:        location_couchdb.longitude,
    county_district:  location_couchdb.county_district,
    creator:          location_couchdb.creator,
    parent_location:  location_couchdb.parent_location,
    changed_by:       location_couchdb.changed_by,
    changed_at:       location_couchdb.changed_at,
    voided:           location_couchdb.voided,
    date_voided:      location_couchdb.date_voided
  )
  puts "Loading Location: #{location.name}"
end

=begin
location_tag_maps = LocationTagMap.all
location_tag_maps.each do |location_tag_map|
  location_tag_map_couch_db = LocationTagMapCouchdb.new
  location_tag_map_couch_db.location_id = location_tag_map.location_id
  location_tag_map_couch_db.location_tag_id = location_tag_map.location_tag_id
  location_tag_map_couch_db.save
end
=end

location_tag_map_couch_dbs = LocationTagMapCouchdb.all
location_tag_map_couch_dbs.each do |location_tag_map_couch_db|
  puts "Location ID: #{location_tag_map_couch_db.location_id}, Location_tag_id: #{location_tag_map_couch_db.location_tag_id}"
  location_tag_map = LocationTagMap.create(
    location_id:      location_tag_map_couch_db.location_id,
    location_tag_id:  location_tag_map_couch_db.location_tag_id
  )
  #puts "Loading LocationTagMap: #{location_tag_map.location_id}"
end

=begin
mode_of_deliveries = ModeOfDelivery.all
mode_of_deliveries.each do |delivery_mode|
  mode_of_delivery_couch_db = ModeOfDeliveryCouchdb.new
  mode_of_delivery_couch_db.mode_of_delivery_id = delivery_mode.mode_of_delivery_id
  mode_of_delivery_couch_db.name = delivery_mode.name
  mode_of_delivery_couch_db.description = delivery_mode.description
  mode_of_delivery_couch_db.save
end
=end

mode_of_delivery_couch_dbs = ModeOfDeliveryCouchdb.all
mode_of_delivery_couch_dbs.each do |mode_of_delivery_couch_db|
  delivery_mode = ModeOfDelivery.create(
    mode_of_delivery_id:  mode_of_delivery_couch_db.mode_of_delivery_id,
    name:                 mode_of_delivery_couch_db.name,
    description:          mode_of_delivery_couch_db.description
  )
  puts "Loading ModeOfDelivery: #{delivery_mode.name}"
end

=begin
person_attribute_types = PersonAttributeType.all
person_attribute_types.each do |person_attribute_type|
  person_attribute_type_couch_db = PersonAttributeTypesCouchdb.new
  person_attribute_type_couch_db.person_attribute_type_id = person_attribute_type.person_attribute_type
  person_attribute_type_couch_db.name = person_attribute_type.name
  person_attribute_type_couch_db.description = person_attribute_type.description
  person_attribute_type_couch_db.save
end
=end

person_attribute_type_couch_dbs = PersonAttributeTypesCouchdb.all
person_attribute_type_couch_dbs.each do |person_attribute_type_couch_db|
  person_attribute_type = PersonAttributeType.create(
    person_attribute_type:  person_attribute_type_couch_db.person_attribute_type_id,
    name:                   person_attribute_type_couch_db.name,
    description:            person_attribute_type_couch_db.description
  )
  puts "Loading PersonAttributeType: #{person_attribute_type.name}"
end

=begin
person_relationship_types = PersonRelationType.all
person_relationship_types.each do |person_relationship_type|
  person_relationship_type_couch_db = PersonRelationshipTypesCouchdb.new
  person_relationship_type_couch_db.person_relationship_type_id = person_relationship_type.person_relationship_type_id
  person_relationship_type_couch_db.name = person_relationship_type.name
  person_relationship_type_couch_db.description = person_relationship_type.description
  person_relationship_type_couch_db.description = person_relationship_type.description
  person_relationship_type_couch_db.save
end
=end

person_relationship_type_couch_dbs = PersonRelationshipTypesCouchdb.all
person_relationship_type_couch_dbs.each do |person_relationship_type_couch_db|
  person_relationship_type = PersonRelationType.create(
    person_relationship_type_id:  person_relationship_type_couch_db.person_relationship_type_id,
    name:                         person_relationship_type_couch_db.name,
    description:                  person_relationship_type_couch_db.description
  )
  puts "Loading PersonRelationType: #{person_relationship_type.name}"
end

=begin
person_type_of_births = PersonTypeOfBirth.all
person_type_of_births.each do |person_type_of_birth|
  person_type_of_births_couch_db = PersonTypeOfBirthsCouchdb.new
  person_type_of_births_couch_db.person_type_of_birth_id = person_type_of_birth.person_type_of_birth_id
  person_type_of_births_couch_db.name = person_type_of_birth.name
  person_type_of_births_couch_db.description = person_type_of_birth.description
  person_type_of_births_couch_db.save
end
=end

person_type_of_births_couch_dbs = PersonTypeOfBirthsCouchdb.all
person_type_of_births_couch_dbs.each do |person_type_of_births_couch_db|
  person_type_of_birth = PersonTypeOfBirth.create(
    person_type_of_birth_id:  person_type_of_births_couch_db.person_type_of_birth_id,
    name:                     person_type_of_births_couch_db.name,
    description:              person_type_of_births_couch_db.description
  )
  puts "Loading PersonTypeOfBirth: #{person_type_of_birth.name}"
end

=begin
statuses = Status.all
statuses.each do |status|
  status_couch_db = StatusCouchdb.new
  status_couch_db.status_id = status.status_id
  status_couch_db.name = status.name
  status_couch_db.description = status.description
  status_couch_db.save
end
=end

status_couch_dbs = StatusCouchdb.all
status_couch_dbs.each do |status_couch_db|
  status = Status.create(
    status_id:    status_couch_db.status_id,
    name:         status_couch_db.name,
    description:  status_couch_db.description
  )
  puts "Loading Status: #{status.name}"
end

person_types = PersonTypeCouchdb.all
person_types.each do |t|
  person_type = PersonType.create(
    person_type_id:   t.person_type_id,
    name:             t.name,
    description:      t.description
  )
  puts "Loading PersonType: #{person_type.name}"
end

roles = RoleCouchdb.all
roles.each do |r|
  role = Role.create(
    role_id:    r.role_id,
    role:       r.role,
    level:      r.level
  )
  puts "Loading Role: #{r.role}"
end
