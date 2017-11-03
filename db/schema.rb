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

ActiveRecord::Schema.define(:version => 20171103151518) do

  create_table "account_logs", :force => true do |t|
    t.integer  "row1"
    t.integer  "row2"
    t.integer  "task_id"
    t.integer  "user_id"
    t.text     "note"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "account_logs", ["task_id"], :name => "index_account_log_associations_on_task_id"
  add_index "account_logs", ["user_id"], :name => "index_account_log_associations_on_user_id"

  create_table "accounts", :force => true do |t|
    t.string   "transaction_type"
    t.float    "amount"
    t.integer  "user_id"
    t.integer  "budget_id"
    t.string   "category"
    t.integer  "task_id"
    t.integer  "job_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "description"
    t.float    "labor_rate"
    t.float    "markup_rate"
    t.integer  "operation_id"
  end

  add_index "accounts", ["budget_id"], :name => "index_accounts_on_budget_id"
  add_index "accounts", ["job_id"], :name => "index_accounts_on_job_id"
  add_index "accounts", ["task_id"], :name => "index_accounts_on_task_id"
  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "allowable_field_types", :force => true do |t|
    t.integer  "field_type_id"
    t.integer  "sample_type_id"
    t.integer  "object_type_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "allowable_field_types", ["field_type_id"], :name => "index_allowable_field_types_on_field_type_id"
  add_index "allowable_field_types", ["object_type_id"], :name => "index_allowable_field_types_on_object_type_id"
  add_index "allowable_field_types", ["sample_type_id"], :name => "index_allowable_field_types_on_sample_type_id"

  create_table "announcements", :force => true do |t|
    t.string   "title"
    t.text     "message"
    t.boolean  "active"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blobs", :force => true do |t|
    t.string   "sha"
    t.string   "path"
    t.text     "xml"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "dir"
    t.integer  "job_id"
  end

  create_table "budgets", :force => true do |t|
    t.string   "name"
    t.float    "overhead"
    t.string   "contact"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
    t.string   "email"
    t.string   "phone"
  end

  create_table "cart_items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "codes", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "parent_id"
    t.string   "parent_class"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "user_id"
  end

  create_table "data_associations", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_class"
    t.string   "key"
    t.integer  "upload_id"
    t.text     "object"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "data_associations", ["upload_id"], :name => "index_data_associations_on_upload_id"

  create_table "field_types", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "ftype"
    t.string   "choices"
    t.boolean  "array"
    t.boolean  "required"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "parent_class"
    t.string   "role"
    t.boolean  "part"
    t.string   "routing"
    t.integer  "preferred_operation_type_id"
    t.integer  "preferred_field_type_id"
  end

  add_index "field_types", ["parent_id"], :name => "index_field_types_on_sample_type_id"

  create_table "field_values", :force => true do |t|
    t.integer  "parent_id"
    t.string   "value"
    t.integer  "child_sample_id"
    t.integer  "child_item_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "name"
    t.string   "parent_class"
    t.string   "role"
    t.integer  "field_type_id"
    t.integer  "row"
    t.integer  "column"
    t.integer  "allowable_field_type_id"
  end

  add_index "field_values", ["allowable_field_type_id"], :name => "index_field_values_on_allowable_field_type_id"
  add_index "field_values", ["field_type_id"], :name => "index_field_values_on_field_type_id"
  add_index "field_values", ["parent_id"], :name => "index_field_values_on_sample_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "year"
    t.integer  "month"
    t.integer  "budget_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "status"
    t.text     "notes"
  end

  create_table "items", :force => true do |t|
    t.string   "location"
    t.integer  "quantity"
    t.integer  "object_type_id"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "inuse",                              :default => 0
    t.integer  "sample_id"
    t.text     "data",           :limit => 16777215
    t.integer  "locator_id"
  end

  add_index "items", ["object_type_id"], :name => "index_items_on_object_type_id"

  create_table "job_associations", :force => true do |t|
    t.integer  "job_id"
    t.integer  "operation_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "jobs", :force => true do |t|
    t.string   "user_id"
    t.string   "sha"
    t.text     "arguments"
    t.text     "state",              :limit => 2147483647
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "path"
    t.integer  "pc"
    t.integer  "group_id"
    t.integer  "submitted_by"
    t.datetime "desired_start_time"
    t.datetime "latest_start_time"
    t.integer  "metacol_id"
    t.integer  "successor_id"
  end

  create_table "libraries", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "locators", :force => true do |t|
    t.integer  "wizard_id"
    t.integer  "item_id"
    t.integer  "number"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.float    "cost"
    t.string   "release_method"
    t.text     "release_description"
    t.integer  "sample_type_id"
    t.string   "image"
    t.string   "prefix"
    t.integer  "rows"
    t.integer  "columns"
  end

  create_table "operation_types", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.boolean  "deployed"
    t.boolean  "on_the_fly"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "operations", :force => true do |t|
    t.integer  "operation_type_id"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.float    "x"
    t.float    "y"
    t.integer  "parent_id"
  end

  add_index "operations", ["operation_type_id"], :name => "index_operations_on_operation_type_id"
  add_index "operations", ["user_id"], :name => "index_operations_on_user_id"

  create_table "parameters", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
    t.integer  "user_id"
  end

  create_table "plan_associations", :force => true do |t|
    t.integer  "plan_id"
    t.integer  "operation_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "plan_associations", ["operation_id"], :name => "index_plan_associations_on_operation_id"
  add_index "plan_associations", ["plan_id"], :name => "index_plan_associations_on_plan_id"

  create_table "plans", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "budget_id"
    t.string   "name"
    t.string   "status"
    t.float    "cost_limit"
    t.string   "folder"
    t.text     "layout"
  end

  add_index "plans", ["user_id"], :name => "index_plans_on_user_id"

  create_table "post_associations", :force => true do |t|
    t.integer  "post_id"
    t.integer  "sample_id"
    t.integer  "item_id"
    t.integer  "job_id"
    t.integer  "task_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "sha"
  end

  create_table "posts", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sample_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "samples", :force => true do |t|
    t.string   "name"
    t.integer  "sample_type_id"
    t.string   "project"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "user_id"
    t.string   "description"
    t.text     "data"
  end

  create_table "takes", :force => true do |t|
    t.integer  "item_id"
    t.integer  "job_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "task_notifications", :force => true do |t|
    t.text     "content"
    t.integer  "task_id"
    t.integer  "job_id"
    t.boolean  "read"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "task_prototypes", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "prototype"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "status_options"
    t.string   "validator"
    t.float    "cost",           :default => 1.0
    t.string   "metacol"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "specification"
    t.string   "status"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "task_prototype_id"
    t.integer  "user_id",           :default => 0
    t.integer  "budget_id"
  end

  create_table "timings", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_class"
    t.string   "days"
    t.integer  "start"
    t.integer  "stop"
    t.boolean  "active"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "touches", :force => true do |t|
    t.integer  "item_id"
    t.integer  "job_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "task_id"
    t.integer  "metacol_id"
  end

  add_index "touches", ["item_id"], :name => "index_touches_on_item_id"
  add_index "touches", ["job_id"], :name => "index_touches_on_job_id"

  create_table "uploads", :force => true do |t|
    t.integer  "job_id"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "user_budget_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "budget_id"
    t.float    "quota"
    t.boolean  "disabled"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
    t.string   "key"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "wires", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.boolean  "active"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "wizards", :force => true do |t|
    t.string   "name"
    t.string   "specification"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "description"
  end

end
