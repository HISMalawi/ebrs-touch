# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 1) do

  create_table "city", primary_key: "city_id", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "country_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "city", ["country_id"], name: "fk_cities_1_idx", using: :btree

  create_table "core_person", primary_key: "person_id", force: :cascade do |t|
    t.integer  "person_type_id", limit: 4, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "core_person", ["person_id"], name: "person_id_UNIQUE", unique: true, using: :btree

  create_table "country", primary_key: "country_id", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "nationality",        limit: 255
    t.string   "continent",          limit: 255
    t.integer  "country_code",       limit: 4
    t.string   "country_short_code", limit: 255
    t.string   "region",             limit: 255
    t.string   "sub_region",         limit: 255
    t.string   "world_region",       limit: 255
    t.string   "currency",           limit: 255
    t.string   "ioc",                limit: 255
    t.string   "gec",                limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "district", primary_key: "district_id", force: :cascade do |t|
    t.string   "name",        limit: 45,             null: false
    t.integer  "region_id",   limit: 4,              null: false
    t.integer  "voided",      limit: 1,  default: 0, null: false
    t.datetime "date_voided"
    t.integer  "voided_by",   limit: 4
    t.string   "void_reason", limit: 45
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "district", ["region_id"], name: "fk_district_1_idx", using: :btree
  add_index "district", ["voided_by"], name: "fk_district_2_idx", using: :btree

  create_table "guardianship", primary_key: "guardianship_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "level_of_education", primary_key: "level_of_education_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "location", primary_key: "location_id", force: :cascade do |t|
    t.string   "name",               limit: 45,  null: false
    t.string   "description",        limit: 100
    t.integer  "location_parent_id", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "location_tag", primary_key: "location_tag_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.integer  "voided_by",   limit: 4
    t.string   "void_reason", limit: 45
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "location_tag", ["location_tag_id"], name: "location_tag_map_id_UNIQUE", unique: true, using: :btree

  create_table "location_tag_map", id: false, force: :cascade do |t|
    t.integer "location_id",     limit: 4, null: false
    t.integer "location_tag_id", limit: 4, null: false
  end

  add_index "location_tag_map", ["location_id"], name: "fk_location_tag_map_1", using: :btree
  add_index "location_tag_map", ["location_tag_id"], name: "fk_location_tag_map_2_idx", using: :btree

  create_table "mode_of_delivery", primary_key: "mode_of_delivery_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "person", primary_key: "person_id", force: :cascade do |t|
    t.string   "gender",              limit: 6,             null: false
    t.integer  "birthdate_estimated", limit: 1, default: 0, null: false
    t.date     "birthdate",                                 null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "person_address", primary_key: "person_addresses_id", force: :cascade do |t|
    t.integer  "person_id",              limit: 4,   null: false
    t.integer  "current_village",        limit: 4
    t.string   "current_village_other",  limit: 255
    t.integer  "current_ta",             limit: 4
    t.string   "current_ta_other",       limit: 255
    t.integer  "current_district",       limit: 4
    t.string   "current_district_other", limit: 255
    t.integer  "home_village",           limit: 4
    t.string   "home_village_other",     limit: 255
    t.integer  "home_ta",                limit: 4
    t.string   "home_ta_other",          limit: 255
    t.integer  "home_district",          limit: 4
    t.string   "home_district_other",    limit: 255
    t.integer  "citizenship",            limit: 4,   null: false
    t.integer  "residential_country",    limit: 4,   null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "person_address", ["citizenship"], name: "fk_person_addresses_8_idx", using: :btree
  add_index "person_address", ["current_district"], name: "fk_person_addresses_4_idx", using: :btree
  add_index "person_address", ["current_ta"], name: "fk_person_addresses_3_idx", using: :btree
  add_index "person_address", ["current_village", "current_ta", "current_district", "home_village", "home_ta", "home_district"], name: "fk_person_addresses_2_idx", using: :btree
  add_index "person_address", ["home_district"], name: "fk_person_addresses_7_idx", using: :btree
  add_index "person_address", ["home_ta"], name: "fk_person_addresses_6_idx", using: :btree
  add_index "person_address", ["home_village"], name: "fk_person_addresses_5_idx", using: :btree
  add_index "person_address", ["person_id"], name: "fk_person_addresses_1_idx", using: :btree
  add_index "person_address", ["residential_country"], name: "fk_person_addresses_9_idx", using: :btree

  create_table "person_attribute", primary_key: "person_attribute_id", force: :cascade do |t|
    t.integer  "person_id",                limit: 4,               null: false
    t.integer  "person_attribute_type_id", limit: 4,               null: false
    t.integer  "voided",                   limit: 1,   default: 0, null: false
    t.string   "value",                    limit: 100,             null: false
    t.integer  "voided_by",                limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "person_attribute", ["person_attribute_type_id"], name: "fk_person_attributes_2_idx", using: :btree
  add_index "person_attribute", ["person_id"], name: "fk_person_attributes_1_idx", using: :btree

  create_table "person_attribute_type", primary_key: "person_attribute_type_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "update_at",                           null: false
  end

  create_table "person_birth_detail", primary_key: "person_birth_details_id", force: :cascade do |t|
    t.integer "person_id",                               limit: 4,              null: false
    t.integer "place_of_birth",                          limit: 4,              null: false
    t.integer "birth_location_id",                       limit: 4,              null: false
    t.string  "other_birth_location",                    limit: 45
    t.float   "birth_weight",                            limit: 24
    t.integer "type_of_birth",                           limit: 4,              null: false
    t.integer "parents_married_to_each_other",           limit: 1,  default: 0, null: false
    t.date    "date_of_marriage"
    t.integer "gestation_at_birth",                      limit: 4
    t.integer "number_of_prenatal_visits",               limit: 4
    t.integer "month_prenatal_care_started",             limit: 4
    t.integer "mode_of_delivery",                        limit: 4,              null: false
    t.integer "number_of_children_born_alive_inclusive", limit: 4,  default: 1, null: false
    t.integer "number_of_children_born_still_alive",     limit: 4,  default: 1, null: false
    t.integer "level_of_education",                      limit: 4,              null: false
    t.string  "district_id_number",                      limit: 20
    t.integer "national_serial_number",                  limit: 4
    t.integer "court_order_attached",                    limit: 1,  default: 0, null: false
    t.date    "acknowledgement_of_receipt_date",                                null: false
    t.string  "facility_serial_number",                  limit: 30
    t.integer "guardianship",                            limit: 4,              null: false
    t.integer "adoption_court_order",                    limit: 1,  default: 0, null: false
  end

  add_index "person_birth_detail", ["birth_location_id"], name: "fk_person_birth_details_3_idx", using: :btree
  add_index "person_birth_detail", ["district_id_number"], name: "district_id_number_UNIQUE", unique: true, using: :btree
  add_index "person_birth_detail", ["facility_serial_number"], name: "facility_serial_number_UNIQUE", unique: true, using: :btree
  add_index "person_birth_detail", ["guardianship"], name: "fk_person_birth_details_6_idx", using: :btree
  add_index "person_birth_detail", ["level_of_education"], name: "fk_person_birth_details_7_idx", using: :btree
  add_index "person_birth_detail", ["mode_of_delivery"], name: "fk_person_birth_details_5_idx", using: :btree
  add_index "person_birth_detail", ["national_serial_number"], name: "national_serial_number_UNIQUE", unique: true, using: :btree
  add_index "person_birth_detail", ["person_id"], name: "fk_person_birth_details_1_idx", using: :btree
  add_index "person_birth_detail", ["place_of_birth"], name: "fk_person_birth_details_4_idx", using: :btree
  add_index "person_birth_detail", ["type_of_birth"], name: "fk_person_birth_details_2_idx", using: :btree

  create_table "person_identifier", primary_key: "person_identifier_id", force: :cascade do |t|
    t.integer  "person_id",       limit: 4,                null: false
    t.string   "identifier",      limit: 50,  default: "", null: false
    t.integer  "identifier_type", limit: 4,                null: false
    t.integer  "preferred",       limit: 2,   default: 0,  null: false
    t.integer  "location_id",     limit: 4,                null: false
    t.integer  "creator",         limit: 4,                null: false
    t.integer  "voided",          limit: 2,   default: 0,  null: false
    t.integer  "voided_by",       limit: 4
    t.datetime "date_voided"
    t.string   "void_reason",     limit: 255
    t.string   "uuid",            limit: 38,               null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "person_identifier", ["creator"], name: "fk_person_identifier_3_idx", using: :btree
  add_index "person_identifier", ["identifier_type"], name: "fk_person_identifier_1_idx", using: :btree
  add_index "person_identifier", ["location_id"], name: "fk_person_identifier_5_idx", using: :btree
  add_index "person_identifier", ["person_id"], name: "fk_person_identifier_2_idx", using: :btree
  add_index "person_identifier", ["voided_by"], name: "fk_person_identifier_4_idx", using: :btree

  create_table "person_identifier_type", primary_key: "person_identifier_type_id", force: :cascade do |t|
    t.string   "name",               limit: 50,    default: "", null: false
    t.text     "description",        limit: 65535,              null: false
    t.string   "format",             limit: 50
    t.integer  "check_digit",        limit: 2,     default: 0,  null: false
    t.string   "required",           limit: 45
    t.integer  "format_description", limit: 2,     default: 0,  null: false
    t.string   "validator",          limit: 200
    t.integer  "retired",            limit: 2,     default: 0,  null: false
    t.integer  "retired_by",         limit: 4
    t.datetime "date_retired"
    t.string   "retire_reason",      limit: 255
    t.string   "uuid",               limit: 38,                 null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "person_identifier_type", ["retired_by"], name: "fk_person_identifier_type_1_idx", using: :btree

  create_table "person_name", primary_key: "person_name_id", force: :cascade do |t|
    t.integer  "person_id",   limit: 4,               null: false
    t.string   "first_name",  limit: 45,              null: false
    t.string   "middle_name", limit: 45
    t.string   "last_name",   limit: 45,              null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "person_name", ["person_id"], name: "fk_person_name_1_idx", using: :btree
  add_index "person_name", ["voided_by"], name: "fk_person_name_2_idx", using: :btree

  create_table "person_name_code", primary_key: "person_name_code_id", force: :cascade do |t|
    t.integer  "person_name_id",   limit: 4,  null: false
    t.string   "first_name_code",  limit: 10, null: false
    t.string   "middle_name_code", limit: 10
    t.string   "last_name_code",   limit: 10, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "person_name_code", ["person_name_id"], name: "fk_person_name_code_1_idx", using: :btree

  create_table "person_record_status", primary_key: "person_record_status_id", force: :cascade do |t|
    t.integer  "status_id",   limit: 4,   null: false
    t.integer  "person_id",   limit: 4,   null: false
    t.integer  "creator",     limit: 4,   null: false
    t.integer  "voided",      limit: 1
    t.string   "void_reason", limit: 100
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "person_record_status", ["creator"], name: "fk_person_record_status_1_idx", using: :btree
  add_index "person_record_status", ["person_id"], name: "fk_person_record_statuses_1_idx", using: :btree
  add_index "person_record_status", ["status_id"], name: "fk_person_record_statuses_2_idx", using: :btree
  add_index "person_record_status", ["voided_by"], name: "fk_person_record_statuses_3_idx", using: :btree

  create_table "person_relationship", primary_key: "person_relationship_id", force: :cascade do |t|
    t.integer  "person_a",                    limit: 4, null: false
    t.integer  "person_b",                    limit: 4, null: false
    t.integer  "person_relationship_type_id", limit: 4, null: false
    t.datetime "created_at",                            null: false
    t.datetime "update_at",                             null: false
  end

  add_index "person_relationship", ["person_a"], name: "fk_person_relationship_1_idx", using: :btree
  add_index "person_relationship", ["person_b"], name: "fk_person_relationship_2_idx", using: :btree
  add_index "person_relationship", ["person_relationship_type_id"], name: "fk_person_relationship_3_idx", using: :btree

  create_table "person_relationship_type", primary_key: "person_relationship_type_id", force: :cascade do |t|
    t.string   "name",        limit: 20,             null: false
    t.integer  "voided",      limit: 1,  default: 0, null: false
    t.string   "description", limit: 45
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
    t.datetime "created_at",                         null: false
    t.datetime "update_at",                          null: false
  end

  create_table "person_type_of_birth", primary_key: "person_type_of_birth_id", force: :cascade do |t|
    t.string   "name",        limit: 45,              null: false
    t.string   "description", limit: 100
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "voided",      limit: 1,   default: 0, null: false
    t.string   "void_reason", limit: 100
    t.integer  "voided_by",   limit: 4
    t.datetime "date_voided"
  end

  create_table "region", primary_key: "region_id", force: :cascade do |t|
    t.string   "name",        limit: 45,             null: false
    t.integer  "country_id",  limit: 4
    t.integer  "voided",      limit: 1,  default: 0, null: false
    t.integer  "voided_by",   limit: 4
    t.string   "void_reason", limit: 45
    t.datetime "date_voided"
    t.datetime "updated_at",                         null: false
    t.datetime "created_at",                         null: false
  end

  add_index "region", ["country_id"], name: "fk_region_1_idx", using: :btree

  create_table "role_activity", primary_key: "role_activity_id", force: :cascade do |t|
    t.string   "activity",    limit: 45,             null: false
    t.integer  "voided",      limit: 1,  default: 0, null: false
    t.datetime "date_voided"
    t.integer  "voided_by",   limit: 4
    t.string   "void_reason", limit: 45
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "role_activity", ["activity"], name: "activity_UNIQUE", unique: true, using: :btree
  add_index "role_activity", ["role_activity_id"], name: "role_activity_id_UNIQUE", unique: true, using: :btree

  create_table "status", primary_key: "status_id", force: :cascade do |t|
    t.string   "name",        limit: 45
    t.string   "description", limit: 100
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "traditional_authority", primary_key: "traditional_authority_id", force: :cascade do |t|
    t.string   "name",        limit: 45,             null: false
    t.integer  "district_id", limit: 4,              null: false
    t.integer  "voided",      limit: 1,  default: 0, null: false
    t.datetime "date_voided"
    t.string   "void_reason", limit: 45
    t.integer  "voided_by",   limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "traditional_authority", ["district_id"], name: "fk_traditional_authority_1_idx", using: :btree
  add_index "traditional_authority", ["voided"], name: "fk_traditional_authority_2_idx", using: :btree
  add_index "traditional_authority", ["voided_by"], name: "fk_traditional_authority_2_idx1", using: :btree

  create_table "user", primary_key: "user_id", force: :cascade do |t|
    t.integer  "location_id",        limit: 4,               null: false
    t.string   "username",           limit: 50,              null: false
    t.string   "plain_password",     limit: 255
    t.string   "password_hash",      limit: 255
    t.integer  "role_id",            limit: 4,               null: false
    t.integer  "active",             limit: 1,   default: 1, null: false
    t.integer  "notify",             limit: 1,   default: 1, null: false
    t.integer  "creator",            limit: 4,   default: 1, null: false
    t.datetime "last_password_date"
    t.integer  "person_id",          limit: 4
    t.integer  "voided",             limit: 1,   default: 0, null: false
    t.integer  "voided_by",          limit: 4
    t.datetime "date_voided"
    t.string   "void_reason",        limit: 255
    t.string   "email",              limit: 100,             null: false
    t.string   "signature",          limit: 100
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at"
    t.string   "uuid",               limit: 38,              null: false
  end

  add_index "user", ["creator"], name: "fk_user_5_idx", using: :btree
  add_index "user", ["location_id"], name: "fk_user_4_idx", using: :btree
  add_index "user", ["person_id"], name: "fk_users_1_idx", using: :btree
  add_index "user", ["role_id"], name: "fk_user_3_idx", using: :btree
  add_index "user", ["username"], name: "username_UNIQUE", unique: true, using: :btree
  add_index "user", ["voided_by"], name: "fk_users_2_idx", using: :btree

  create_table "user_role", primary_key: "user_role_id", force: :cascade do |t|
    t.string   "role",        limit: 45,  null: false
    t.string   "level",       limit: 45,  null: false
    t.integer  "voided",      limit: 1,   null: false
    t.datetime "date_voided"
    t.string   "void_reason", limit: 100
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "user_role_activity", id: false, force: :cascade do |t|
    t.integer  "user_role_id",     limit: 4,               null: false
    t.integer  "role_activity_id", limit: 4,               null: false
    t.integer  "voided",           limit: 1,   default: 0, null: false
    t.integer  "voided_by",        limit: 4
    t.string   "void_reason",      limit: 100
    t.datetime "date_voided"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_role_activity", ["role_activity_id"], name: "fk_user_role_activity_2_idx", using: :btree
  add_index "user_role_activity", ["user_role_id"], name: "fk_user_role_activity_1", using: :btree

  create_table "village", primary_key: "village_id", force: :cascade do |t|
    t.string   "name",                     limit: 45,             null: false
    t.integer  "traditional_authority_id", limit: 4,              null: false
    t.integer  "voided",                   limit: 1,  default: 0, null: false
    t.integer  "voided_by",                limit: 4
    t.string   "void_reason",              limit: 45
    t.datetime "date_voided"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "village", ["traditional_authority_id"], name: "fk_village_1_idx", using: :btree
  add_index "village", ["voided_by"], name: "fk_village_2_idx", using: :btree

  add_foreign_key "city", "country", primary_key: "country_id", name: "fk_cities_1"
  add_foreign_key "district", "region", primary_key: "region_id", name: "fk_district_1"
  add_foreign_key "district", "user", column: "voided_by", primary_key: "user_id", name: "fk_district_2"
  add_foreign_key "location_tag_map", "location", primary_key: "location_id", name: "fk_location_tag_map_1"
  add_foreign_key "location_tag_map", "location_tag", primary_key: "location_tag_id", name: "fk_location_tag_map_2"
  add_foreign_key "person", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_1"
  add_foreign_key "person_address", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_addresses_1"
  add_foreign_key "person_address", "country", column: "citizenship", primary_key: "country_id", name: "fk_person_addresses_8"
  add_foreign_key "person_address", "country", column: "residential_country", primary_key: "country_id", name: "fk_person_addresses_9"
  add_foreign_key "person_address", "district", column: "current_district", primary_key: "district_id", name: "fk_person_addresses_4"
  add_foreign_key "person_address", "district", column: "home_district", primary_key: "district_id", name: "fk_person_addresses_7"
  add_foreign_key "person_address", "traditional_authority", column: "current_ta", primary_key: "traditional_authority_id", name: "fk_person_addresses_3"
  add_foreign_key "person_address", "traditional_authority", column: "home_ta", primary_key: "traditional_authority_id", name: "fk_person_addresses_6"
  add_foreign_key "person_address", "village", column: "current_village", primary_key: "village_id", name: "fk_person_addresses_2"
  add_foreign_key "person_address", "village", column: "home_village", primary_key: "village_id", name: "fk_person_addresses_5"
  add_foreign_key "person_attribute", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_attributes_1"
  add_foreign_key "person_attribute", "person_attribute_type", primary_key: "person_attribute_type_id", name: "fk_person_attributes_2"
  add_foreign_key "person_birth_detail", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_birth_details_1"
  add_foreign_key "person_birth_detail", "guardianship", column: "guardianship", primary_key: "guardianship_id", name: "fk_person_birth_details_6"
  add_foreign_key "person_birth_detail", "level_of_education", column: "level_of_education", primary_key: "level_of_education_id", name: "fk_person_birth_details_4"
  add_foreign_key "person_birth_detail", "location", column: "birth_location_id", primary_key: "location_id", name: "fk_person_birth_details_3"
  add_foreign_key "person_birth_detail", "location", column: "place_of_birth", primary_key: "location_id", name: "fk_person_birth_details_2"
  add_foreign_key "person_birth_detail", "mode_of_delivery", column: "mode_of_delivery", primary_key: "mode_of_delivery_id", name: "fk_person_birth_details_5"
  add_foreign_key "person_birth_detail", "person_type_of_birth", column: "type_of_birth", primary_key: "person_type_of_birth_id", name: "fk_person_birth_details_7"
  add_foreign_key "person_identifier", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_identifier_2"
  add_foreign_key "person_identifier", "location", primary_key: "location_id", name: "fk_person_identifier_5"
  add_foreign_key "person_identifier", "person_identifier_type", column: "identifier_type", primary_key: "person_identifier_type_id", name: "fk_person_identifier_1"
  add_foreign_key "person_identifier", "user", column: "creator", primary_key: "user_id", name: "fk_person_identifier_3"
  add_foreign_key "person_identifier", "user", column: "voided_by", primary_key: "user_id", name: "fk_person_identifier_4"
  add_foreign_key "person_identifier_type", "user", column: "retired_by", primary_key: "user_id", name: "fk_person_identifier_type_1"
  add_foreign_key "person_name", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_name_1"
  add_foreign_key "person_name", "user", column: "voided_by", primary_key: "user_id", name: "fk_person_name_2"
  add_foreign_key "person_name_code", "person_name", primary_key: "person_name_id", name: "fk_person_name_code_1"
  add_foreign_key "person_record_status", "core_person", column: "person_id", primary_key: "person_id", name: "fk_person_record_statuses_1"
  add_foreign_key "person_record_status", "status", primary_key: "status_id", name: "fk_person_record_statuses_2"
  add_foreign_key "person_record_status", "user", column: "creator", primary_key: "user_id", name: "fk_person_record_status_1"
  add_foreign_key "person_record_status", "user", column: "voided_by", primary_key: "user_id", name: "fk_person_record_statuses_3"
  add_foreign_key "person_relationship", "core_person", column: "person_a", primary_key: "person_id", name: "fk_person_relationship_1"
  add_foreign_key "person_relationship", "core_person", column: "person_b", primary_key: "person_id", name: "fk_person_relationship_2"
  add_foreign_key "person_relationship", "person_relationship_type", primary_key: "person_relationship_type_id", name: "fk_person_relationship_3"
  add_foreign_key "region", "country", primary_key: "country_id", name: "fk_region_1"
  add_foreign_key "traditional_authority", "district", primary_key: "district_id", name: "fk_traditional_authority_1"
  add_foreign_key "traditional_authority", "user", column: "voided_by", primary_key: "user_id", name: "fk_traditional_authority_2"
  add_foreign_key "user", "core_person", column: "person_id", primary_key: "person_id", name: "fk_user_1"
  add_foreign_key "user", "core_person", column: "voided_by", primary_key: "person_id", name: "fk_user_2"
  add_foreign_key "user", "location", primary_key: "location_id", name: "fk_user_4"
  add_foreign_key "user", "user", column: "creator", primary_key: "user_id", name: "fk_user_5"
  add_foreign_key "user", "user_role", column: "role_id", primary_key: "user_role_id", name: "fk_user_3"
  add_foreign_key "user_role_activity", "role_activity", primary_key: "role_activity_id", name: "fk_user_role_activity_2"
  add_foreign_key "user_role_activity", "user_role", primary_key: "user_role_id", name: "fk_user_role_activity_1"
  add_foreign_key "village", "traditional_authority", primary_key: "traditional_authority_id", name: "fk_village_1"
  add_foreign_key "village", "user", column: "voided_by", primary_key: "user_id", name: "fk_village_2"
end
