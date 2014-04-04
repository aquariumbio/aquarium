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

ActiveRecord::Schema.define(:version => 20140404204258) do

  create_table "blobs", :force => true do |t|
    t.string   "sha"
    t.string   "path"
    t.text     "xml"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "dir"
    t.integer  "job_id"
  end

  create_table "cart_items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "collections", :force => true do |t|
    t.string   "name"
    t.string   "project"
    t.integer  "object_type_id"
    t.integer  "rows"
    t.integer  "columns"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "location"
    t.string   "description"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "location"
    t.integer  "quantity"
    t.integer  "object_type_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "inuse",          :default => 0
    t.integer  "sample_id"
    t.string   "data"
    t.integer  "collection_id"
  end

  add_index "items", ["object_type_id"], :name => "index_items_on_object_type_id"

  create_table "jobs", :force => true do |t|
    t.string   "user_id"
    t.string   "sha"
    t.text     "arguments"
    t.text     "state"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "path"
    t.integer  "pc"
    t.integer  "group_id"
    t.integer  "submitted_by"
    t.datetime "desired_start_time"
    t.datetime "latest_start_time"
    t.integer  "metacol_id"
  end

  create_table "logs", :force => true do |t|
    t.integer  "job_id"
    t.string   "user_id"
    t.string   "entry_type"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "metacols", :force => true do |t|
    t.string   "path"
    t.string   "sha"
    t.text     "state"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "message"
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
    t.datetime "image_updated_at"
    t.float    "cost"
    t.string   "release_method"
    t.text     "release_description"
    t.integer  "sample_type_id"
    t.string   "image"
    t.string   "prefix"
  end

  create_table "parts", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "row"
    t.integer  "column"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "item_id1"
    t.integer  "item_id2"
    t.integer  "item_id3"
    t.integer  "item_id4"
    t.string   "data"
  end

  create_table "sample_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "field1name"
    t.string   "field1type"
    t.string   "field2name"
    t.string   "field2type"
    t.string   "field3name"
    t.string   "field3type"
    t.string   "field4name"
    t.string   "field4type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "field5name"
    t.string   "field5type"
    t.string   "field6name"
    t.string   "field6type"
    t.string   "field7name"
    t.string   "field7type"
    t.string   "field8name"
    t.string   "field8type"
  end

  create_table "samples", :force => true do |t|
    t.string   "name"
    t.integer  "sample_type_id"
    t.string   "project"
    t.string   "field1"
    t.string   "field2"
    t.string   "field3"
    t.string   "field4"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "field5"
    t.string   "field6"
    t.integer  "user_id"
    t.string   "description"
    t.string   "field7"
    t.string   "field8"
  end

  create_table "task_prototypes", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "prototype"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.string   "specification"
    t.string   "status"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "task_prototype_id"
  end

  create_table "touches", :force => true do |t|
    t.integer  "item_id"
    t.integer  "job_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "touches", ["item_id"], :name => "index_touches_on_item_id"
  add_index "touches", ["job_id"], :name => "index_touches_on_job_id"

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
