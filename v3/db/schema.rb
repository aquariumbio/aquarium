# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_10_000001) do

  create_table "account_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "row1"
    t.integer "row2"
    t.integer "user_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["row1"], name: "index_account_logs_on_row1"
    t.index ["row2"], name: "index_account_logs_on_row2"
    t.index ["user_id"], name: "index_account_log_associations_on_user_id"
  end

  create_table "accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "transaction_type"
    t.float "amount"
    t.integer "user_id"
    t.integer "budget_id"
    t.string "category"
    t.integer "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.float "labor_rate"
    t.float "markup_rate"
    t.integer "operation_id"
    t.index ["budget_id"], name: "index_accounts_on_budget_id"
    t.index ["job_id"], name: "index_accounts_on_job_id"
    t.index ["operation_id"], name: "index_accounts_on_operation_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "allowable_field_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "field_type_id"
    t.integer "sample_type_id"
    t.integer "object_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_type_id"], name: "index_allowable_field_types_on_field_type_id"
    t.index ["object_type_id"], name: "index_allowable_field_types_on_object_type_id"
    t.index ["sample_type_id"], name: "index_allowable_field_types_on_sample_type_id"
  end

  create_table "announcements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "title"
    t.text "message"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budgets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.float "overhead"
    t.string "contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "email"
    t.string "phone"
  end

  create_table "codes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.integer "parent_id"
    t.string "parent_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "data_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "parent_id"
    t.string "parent_class"
    t.string "key"
    t.integer "upload_id"
    t.text "object"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_class", "parent_id"], name: "index_data_associations_on_parent_class_and_parent_id"
    t.index ["upload_id"], name: "index_data_associations_on_upload_id"
  end

  create_table "field_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "parent_id"
    t.string "name"
    t.string "ftype"
    t.string "choices"
    t.boolean "array"
    t.boolean "required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "parent_class"
    t.string "role"
    t.boolean "part"
    t.string "routing"
    t.integer "preferred_operation_type_id"
    t.integer "preferred_field_type_id"
    t.index ["parent_class", "parent_id"], name: "index_field_types_on_parent_class_and_parent_id"
  end

  create_table "field_values", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "parent_id"
    t.text "value"
    t.integer "child_sample_id"
    t.integer "child_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "parent_class"
    t.string "role"
    t.integer "field_type_id"
    t.integer "row"
    t.integer "column"
    t.integer "allowable_field_type_id"
    t.index ["allowable_field_type_id"], name: "index_field_values_on_allowable_field_type_id"
    t.index ["child_item_id"], name: "fk_rails_319b222007"
    t.index ["child_sample_id"], name: "fk_rails_e04e5b0273"
    t.index ["field_type_id"], name: "index_field_values_on_field_type_id"
    t.index ["parent_class", "parent_id"], name: "index_field_values_on_parent_class_and_parent_id"
  end

  create_table "groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.integer "budget_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.text "notes"
    t.index ["budget_id"], name: "index_invoices_on_budget_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "location"
    t.integer "quantity"
    t.integer "object_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inuse", default: 0
    t.integer "sample_id"
    t.text "data", size: :medium
    t.integer "locator_id"
    t.index ["locator_id"], name: "index_items_on_locator_id"
    t.index ["object_type_id"], name: "index_items_on_object_type_id"
    t.index ["sample_id"], name: "index_items_on_sample_id"
  end

  create_table "job_assignment_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "job_id"
    t.integer "assigned_by"
    t.integer "assigned_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by"], name: "index_job_assignment_logs_on_assigned_by"
    t.index ["assigned_to"], name: "index_job_assignment_logs_on_assigned_to"
    t.index ["job_id"], name: "index_job_assignment_logs_on_job_id"
  end

  create_table "job_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "job_id"
    t.integer "operation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_associations_on_job_id"
    t.index ["operation_id"], name: "index_job_associations_on_operation_id"
  end

  create_table "jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.text "arguments"
    t.text "state", size: :long
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "path"
    t.integer "pc"
    t.integer "group_id"
    t.integer "submitted_by"
    t.datetime "desired_start_time"
    t.datetime "latest_start_time"
    t.integer "metacol_id"
    t.integer "successor_id"
    t.index ["group_id"], name: "index_jobs_on_group_id"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "libraries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locators", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "wizard_id"
    t.integer "item_id"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_locators_on_item_id"
    t.index ["wizard_id"], name: "index_locators_on_wizard_id"
  end

  create_table "logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "job_id"
    t.integer "user_id"
    t.string "entry_type"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_logs_on_job_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "memberships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "user_id"], name: "group_id_user_id", unique: true
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "object_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "min"
    t.integer "max"
    t.string "handler"
    t.text "safety"
    t.text "cleanup"
    t.text "data"
    t.text "vendor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unit"
    t.float "cost"
    t.string "release_method"
    t.text "release_description"
    t.integer "sample_type_id"
    t.string "image"
    t.string "prefix"
    t.integer "rows"
    t.integer "columns"
  end

  create_table "operation_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.boolean "deployed"
    t.boolean "on_the_fly"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "name"], name: "index_operation_types_on_category_and_name", unique: true
  end

  create_table "operations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "operation_type_id"
    t.string "status"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "x"
    t.float "y"
    t.integer "parent_id"
    t.index ["operation_type_id"], name: "index_operations_on_operation_type_id"
    t.index ["user_id"], name: "index_operations_on_user_id"
  end

  create_table "parameters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "user_id"
  end

  create_table "part_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "part_id"
    t.integer "collection_id"
    t.integer "row"
    t.integer "column"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["collection_id", "row", "column"], name: "index_part_associations_on_collection_id_and_row_and_column", unique: true
    t.index ["part_id"], name: "index_part_associations_on_part_id"
  end

  create_table "plan_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "plan_id"
    t.integer "operation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operation_id"], name: "index_plan_associations_on_operation_id"
    t.index ["plan_id"], name: "index_plan_associations_on_plan_id"
  end

  create_table "plans", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "budget_id"
    t.string "name"
    t.string "status"
    t.float "cost_limit"
    t.string "folder"
    t.text "layout"
    t.index ["budget_id"], name: "index_plans_on_budget_id"
    t.index ["user_id"], name: "index_plans_on_user_id"
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "sort"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_operation_types_on_category_and_name", unique: true
  end

  create_table "sample_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "samples", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "sample_type_id"
    t.string "project"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "description"
    t.text "data"
    t.index ["sample_type_id"], name: "index_samples_on_sample_type_id"
    t.index ["user_id"], name: "index_samples_on_user_id"
  end

  create_table "timings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "parent_id"
    t.string "parent_class"
    t.string "days"
    t.integer "start"
    t.integer "stop"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_class", "parent_id"], name: "index_timings_on_parent_class_and_parent_id"
  end

  create_table "uploads", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "job_id"
    t.string "upload_file_name"
    t.string "upload_content_type"
    t.integer "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_uploads_on_job_id"
  end

  create_table "user_budget_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "budget_id"
    t.float "quota"
    t.boolean "disabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_user_budget_associations_on_budget_id"
    t.index ["user_id"], name: "index_user_budget_associations_on_user_id"
  end

  create_table "user_tokens", primary_key: ["ip", "token"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", limit: 128, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip", limit: 18, null: false
    t.datetime "timenow", null: false
    t.index ["user_id"], name: "fk_user_tokens_user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "login"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_token"
    t.boolean "admin", default: false
    t.string "key"
    t.string "role_ids", default: "."
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "wires", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_id"], name: "index_wires_on_from_id"
    t.index ["to_id"], name: "index_wires_on_to_id"
  end

  create_table "wizards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "specification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
  end

  create_table "workers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "message"
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "account_logs", "accounts", column: "row1", on_delete: :cascade
  add_foreign_key "account_logs", "accounts", column: "row2", on_delete: :cascade
  add_foreign_key "account_logs", "users", on_delete: :cascade
  add_foreign_key "accounts", "budgets", on_delete: :cascade
  add_foreign_key "accounts", "jobs", on_delete: :cascade
  add_foreign_key "accounts", "operations", on_delete: :cascade
  add_foreign_key "accounts", "users", on_delete: :cascade
  add_foreign_key "allowable_field_types", "field_types", on_delete: :cascade
  add_foreign_key "allowable_field_types", "object_types", on_delete: :cascade
  add_foreign_key "allowable_field_types", "sample_types", on_delete: :cascade
  add_foreign_key "data_associations", "uploads", on_delete: :cascade
  add_foreign_key "field_values", "allowable_field_types", on_delete: :cascade
  add_foreign_key "field_values", "field_types", on_delete: :cascade
  add_foreign_key "field_values", "items", column: "child_item_id", on_delete: :cascade
  add_foreign_key "field_values", "samples", column: "child_sample_id", on_delete: :cascade
  add_foreign_key "invoices", "budgets", on_delete: :cascade
  add_foreign_key "invoices", "users", on_delete: :cascade
  add_foreign_key "items", "locators", on_delete: :cascade
  add_foreign_key "items", "object_types", on_delete: :cascade
  add_foreign_key "items", "samples", on_delete: :cascade
  add_foreign_key "job_assignment_logs", "jobs", on_delete: :cascade
  add_foreign_key "job_assignment_logs", "users", column: "assigned_by", on_delete: :cascade
  add_foreign_key "job_assignment_logs", "users", column: "assigned_to", on_delete: :cascade
  add_foreign_key "job_associations", "jobs", on_delete: :cascade
  add_foreign_key "job_associations", "operations", on_delete: :cascade
  add_foreign_key "jobs", "groups", on_delete: :cascade
  add_foreign_key "jobs", "users", on_delete: :cascade
  add_foreign_key "locators", "items", on_delete: :cascade
  add_foreign_key "locators", "wizards", on_delete: :cascade
  add_foreign_key "logs", "jobs", on_delete: :cascade
  add_foreign_key "logs", "users", on_delete: :cascade
  add_foreign_key "memberships", "groups", on_delete: :cascade
  add_foreign_key "memberships", "users", on_delete: :cascade
  add_foreign_key "operations", "operation_types", on_delete: :cascade
  add_foreign_key "operations", "users", on_delete: :cascade
  add_foreign_key "part_associations", "items", column: "collection_id", on_delete: :cascade
  add_foreign_key "part_associations", "items", column: "part_id", on_delete: :cascade
  add_foreign_key "plan_associations", "operations", on_delete: :cascade
  add_foreign_key "plan_associations", "plans", on_delete: :cascade
  add_foreign_key "plans", "budgets", on_delete: :cascade
  add_foreign_key "plans", "users", on_delete: :cascade
  add_foreign_key "samples", "sample_types", on_delete: :cascade
  add_foreign_key "samples", "users", on_delete: :cascade
  add_foreign_key "uploads", "jobs", on_delete: :cascade
  add_foreign_key "user_budget_associations", "budgets", on_delete: :cascade
  add_foreign_key "user_budget_associations", "users", on_delete: :cascade
  add_foreign_key "user_tokens", "users", name: "fk_user_tokens_user_id", on_delete: :cascade
  add_foreign_key "wires", "field_values", column: "from_id", on_delete: :cascade
  add_foreign_key "wires", "field_values", column: "to_id", on_delete: :cascade
end
