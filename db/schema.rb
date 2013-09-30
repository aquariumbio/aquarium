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

ActiveRecord::Schema.define(:version => 20130930164148) do

  create_table "blobs", :force => true do |t|
    t.string   "sha"
    t.string   "path"
    t.text     "xml"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "dir"
    t.integer  "job_id"
  end

  create_table "items", :force => true do |t|
    t.string   "location"
    t.integer  "quantity"
    t.integer  "object_type_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "inuse",          :default => 0
    t.string   "table"
    t.integer  "table_entry_id"
  end

  add_index "items", ["object_type_id"], :name => "index_items_on_object_type_id"

  create_table "jobs", :force => true do |t|
    t.string   "user_id"
    t.string   "sha"
    t.text     "arguments"
    t.text     "state"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "path"
    t.integer  "pc"
  end

  create_table "logs", :force => true do |t|
    t.integer  "job_id"
    t.string   "user_id"
    t.string   "entry_type"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "object_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "min"
    t.integer  "max"
    t.string   "handler"
    t.text     "safety"
    t.text     "cleanup"
    t.text     "data"
    t.text     "vendor"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "unit"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.float    "cost"
    t.string   "release_method"
    t.text     "release_description"
  end

  create_table "primers", :force => true do |t|
    t.string   "description"
    t.string   "annealing"
    t.string   "overhang"
    t.float    "tm"
    t.text     "notes"
    t.integer  "project"
    t.integer  "owner"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
