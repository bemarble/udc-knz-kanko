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

ActiveRecord::Schema.define(version: 20150111070115) do

  create_table "opendatas", force: :cascade do |t|
    t.integer  "open_id",    limit: 4
    t.float    "latitude",   limit: 24
    t.float    "longitude",  limit: 24
    t.string   "name",       limit: 255
    t.string   "desc",       limit: 255
    t.string   "tel",        limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter",    limit: 255
    t.string   "facebook",   limit: 255
    t.string   "none",       limit: 255
    t.string   "want2go",    limit: 255
    t.integer  "helpme",     limit: 4
  end

end
