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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130515093930) do

  create_table "admins", :force => true do |t|
    t.string   "uid"
    t.string   "name"
    t.string   "password"
    t.integer  "level"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "interests", :force => true do |t|
    t.string   "name"
    t.integer  "active"
    t.string   "interest_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "pre_regists", :force => true do |t|
    t.string   "mEmail"
    t.string   "mUsername"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "userid"
    t.string   "password"
    t.string   "userpic"
    t.string   "fuid"
    t.string   "tuid"
    t.string   "interest"
    t.string   "noti"
    t.string   "coverpic"
    t.string   "dob"
    t.string   "local"
    t.string   "job"
    t.string   "phone"
    t.string   "comment"
    t.string   "email_auth"
    t.string   "userpicname"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "fbauth"
    t.string   "tauth"
    t.string   "tsecret"
    t.integer  "sex",         :limit => 1
    t.string   "tid"
    t.string   "guid"
    t.string   "gauth"
    t.string   "kakao"
    t.string   "adtoken"
    t.string   "gdtoken"
    t.integer  "phone_auth",  :limit => 1
    t.integer  "acct_auth",   :limit => 1
    t.string   "category"
    t.string   "bank"
    t.string   "account"
    t.string   "holder"
    t.string   "members"
    t.integer  "cert_auth",   :limit => 1
    t.string   "certpic"
    t.integer  "point"
  end

  add_index "users", ["userid"], :name => "userid"

end
