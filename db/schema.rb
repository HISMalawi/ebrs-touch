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

ActiveRecord::Schema.define(version: 20170508085753) do

  create_table "people", id: false, force: :cascade do |t|
    t.integer  "person_id",           limit: 4
    t.integer  "person_type_id",      limit: 4,                   null: false
    t.string   "first_name",          limit: 255,                 null: false
    t.string   "middle_name",         limit: 255
    t.string   "last_name",           limit: 255,                 null: false
    t.string   "gender",              limit: 255,                 null: false
    t.datetime "birthdate",                                       null: false
    t.boolean  "birthdate_estimated",             default: false, null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "person_addresses", force: :cascade do |t|
    t.integer  "person_address_id",      limit: 4,   null: false
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

  create_table "person_relationships", force: :cascade do |t|
    t.integer  "person_relationship_id", limit: 4
    t.integer  "primary_person_id",      limit: 4
    t.integer  "secondary_person_id",    limit: 4
    t.string   "person_relationship",    limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "person_types", force: :cascade do |t|
    t.integer  "person_type_id",   limit: 4
    t.string   "person_type_name", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

end
