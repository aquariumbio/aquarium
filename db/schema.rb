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

ActiveRecord::Schema.define(version: 20200810000001) do

  create_table "account_logs", force: :cascade do |t|
    t.integer  "row1",       limit: 4
    t.integer  "row2",       limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "note",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "account_logs", ["user_id"], name: "index_account_log_associations_on_user_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "transaction_type", limit: 255
    t.float    "amount",           limit: 24
    t.integer  "user_id",          limit: 4
    t.integer  "budget_id",        limit: 4
    t.string   "category",         limit: 255
    t.integer  "job_id",           limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "description",      limit: 65535
    t.float    "labor_rate",       limit: 24
    t.float    "markup_rate",      limit: 24
    t.integer  "operation_id",     limit: 4
  end

  add_index "accounts", ["budget_id"], name: "index_accounts_on_budget_id", using: :btree
  add_index "accounts", ["job_id"], name: "index_accounts_on_job_id", using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "allowable_field_types", force: :cascade do |t|
    t.integer  "field_type_id",  limit: 4
    t.integer  "sample_type_id", limit: 4
    t.integer  "object_type_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "allowable_field_types", ["field_type_id"], name: "index_allowable_field_types_on_field_type_id", using: :btree
  add_index "allowable_field_types", ["object_type_id"], name: "index_allowable_field_types_on_object_type_id", using: :btree
  add_index "allowable_field_types", ["sample_type_id"], name: "index_allowable_field_types_on_sample_type_id", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "message",    limit: 65535
    t.boolean  "active"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "budgets", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.float    "overhead",    limit: 24
    t.string   "contact",     limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "description", limit: 65535
    t.string   "email",       limit: 255
    t.string   "phone",       limit: 255
  end

  create_table "codes", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "content",      limit: 65535
    t.integer  "parent_id",    limit: 4
    t.string   "parent_class", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id",      limit: 4
  end

  create_table "data_associations", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "parent_class", limit: 255
    t.string   "key",          limit: 255
    t.integer  "upload_id",    limit: 4
    t.text     "object",       limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "data_associations", ["upload_id"], name: "index_data_associations_on_upload_id", using: :btree

  create_table "field_types", force: :cascade do |t|
    t.integer  "parent_id",                   limit: 4
    t.string   "name",                        limit: 255
    t.string   "ftype",                       limit: 255
    t.string   "choices",                     limit: 255
    t.boolean  "array"
    t.boolean  "required"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "parent_class",                limit: 255
    t.string   "role",                        limit: 255
    t.boolean  "part"
    t.string   "routing",                     limit: 255
    t.integer  "preferred_operation_type_id", limit: 4
    t.integer  "preferred_field_type_id",     limit: 4
  end

  create_table "field_values", force: :cascade do |t|
    t.integer  "parent_id",               limit: 4
    t.text     "value",                   limit: 65535
    t.integer  "child_sample_id",         limit: 4
    t.integer  "child_item_id",           limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "name",                    limit: 255
    t.string   "parent_class",            limit: 255
    t.string   "role",                    limit: 255
    t.integer  "field_type_id",           limit: 4
    t.integer  "row",                     limit: 4
    t.integer  "column",                  limit: 4
    t.integer  "allowable_field_type_id", limit: 4
  end

  add_index "field_values", ["allowable_field_type_id"], name: "index_field_values_on_allowable_field_type_id", using: :btree
  add_index "field_values", ["field_type_id"], name: "index_field_values_on_field_type_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "year",       limit: 4
    t.integer  "month",      limit: 4
    t.integer  "budget_id",  limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "status",     limit: 255
    t.text     "notes",      limit: 65535
  end

  create_table "items", force: :cascade do |t|
    t.string   "location",       limit: 255
    t.integer  "quantity",       limit: 4
    t.integer  "object_type_id", limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "inuse",          limit: 4,        default: 0
    t.integer  "sample_id",      limit: 4
    t.text     "data",           limit: 16777215
    t.integer  "locator_id",     limit: 4
  end

  add_index "items", ["object_type_id"], name: "index_items_on_object_type_id", using: :btree

  create_table "job_associations", force: :cascade do |t|
    t.integer  "job_id",       limit: 4
    t.integer  "operation_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "user_id",            limit: 255
    t.text     "arguments",          limit: 65535
    t.text     "state",              limit: 4294967295
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "path",               limit: 255
    t.integer  "pc",                 limit: 4
    t.integer  "group_id",           limit: 4
    t.integer  "submitted_by",       limit: 4
    t.datetime "desired_start_time"
    t.datetime "latest_start_time"
    t.integer  "metacol_id",         limit: 4
    t.integer  "successor_id",       limit: 4
  end

  create_table "libraries", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "locators", force: :cascade do |t|
    t.integer  "wizard_id",  limit: 4
    t.integer  "item_id",    limit: 4
    t.integer  "number",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "logs", force: :cascade do |t|
    t.integer  "job_id",     limit: 4
    t.string   "user_id",    limit: 255
    t.string   "entry_type", limit: 255
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "object_types", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "description",         limit: 255
    t.integer  "min",                 limit: 4
    t.integer  "max",                 limit: 4
    t.string   "handler",             limit: 255
    t.text     "safety",              limit: 65535
    t.text     "cleanup",             limit: 65535
    t.text     "data",                limit: 65535
    t.text     "vendor",              limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "unit",                limit: 255
    t.float    "cost",                limit: 24
    t.string   "release_method",      limit: 255
    t.text     "release_description", limit: 65535
    t.integer  "sample_type_id",      limit: 4
    t.string   "image",               limit: 255
    t.string   "prefix",              limit: 255
    t.integer  "rows",                limit: 4
    t.integer  "columns",             limit: 4
  end

  create_table "operation_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "category",   limit: 255
    t.boolean  "deployed"
    t.boolean  "on_the_fly"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "operation_types", ["category", "name"], name: "index_operation_types_on_category_and_name", unique: true, using: :btree

  create_table "operations", force: :cascade do |t|
    t.integer  "operation_type_id", limit: 4
    t.string   "status",            limit: 255
    t.integer  "user_id",           limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.float    "x",                 limit: 24
    t.float    "y",                 limit: 24
    t.integer  "parent_id",         limit: 4
  end

  add_index "operations", ["operation_type_id"], name: "index_operations_on_operation_type_id", using: :btree
  add_index "operations", ["user_id"], name: "index_operations_on_user_id", using: :btree

  create_table "parameters", force: :cascade do |t|
    t.string   "key",         limit: 255
    t.string   "value",       limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "description", limit: 65535
    t.integer  "user_id",     limit: 4
  end

  create_table "part_associations", force: :cascade do |t|
    t.integer  "part_id",       limit: 4
    t.integer  "collection_id", limit: 4
    t.integer  "row",           limit: 4
    t.integer  "column",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "part_associations", ["collection_id", "row", "column"], name: "index_part_associations_on_collection_id_and_row_and_column", unique: true, using: :btree

  create_table "plan_associations", force: :cascade do |t|
    t.integer  "plan_id",      limit: 4
    t.integer  "operation_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "plan_associations", ["operation_id"], name: "index_plan_associations_on_operation_id", using: :btree
  add_index "plan_associations", ["plan_id"], name: "index_plan_associations_on_plan_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "budget_id",  limit: 4
    t.string   "name",       limit: 255
    t.string   "status",     limit: 255
    t.float    "cost_limit", limit: 24
    t.string   "folder",     limit: 255
    t.text     "layout",     limit: 65535
  end

  add_index "plans", ["user_id"], name: "index_plans_on_user_id", using: :btree

  create_table "sample_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "samples", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "sample_type_id", limit: 4
    t.string   "project",        limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_id",        limit: 4
    t.string   "description",    limit: 255
    t.text     "data",           limit: 65535
  end

  create_table "timings", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.string   "parent_class", limit: 255
    t.string   "days",         limit: 255
    t.integer  "start",        limit: 4
    t.integer  "stop",         limit: 4
    t.boolean  "active"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "uploads", force: :cascade do |t|
    t.integer  "job_id",              limit: 4
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size",    limit: 4
    t.datetime "upload_updated_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "user_budget_associations", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "budget_id",  limit: 4
    t.float    "quota",      limit: 24
    t.boolean  "disabled"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "login",           limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "password_digest", limit: 255
    t.string   "remember_token",  limit: 255
    t.boolean  "admin",                       default: false
    t.string   "key",             limit: 255
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "wires", force: :cascade do |t|
    t.integer  "from_id",    limit: 4
    t.integer  "to_id",      limit: 4
    t.boolean  "active"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "wizards", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "specification", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "description",   limit: 255
  end

  create_table "workers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "message",    limit: 255
    t.string   "status",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
