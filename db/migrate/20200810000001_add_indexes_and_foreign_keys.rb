# typed: false
class AddIndexesAndForeignKeys < ActiveRecord::Migration

  def change

    # account_logs
    # already indexed on user_id
    add_index       :account_logs, :row1
    add_index       :account_logs, :row2
    add_foreign_key :account_logs, :users, on_delete: :cascade
    add_foreign_key :account_logs, :accounts, column: "row1", on_delete: :cascade
    add_foreign_key :account_logs, :accounts, column: "row2", on_delete: :cascade

    # accounts
    # already indexed on budget_id
    # already indexed on job_id
    # already indexed on user_id
    add_index       :accounts, :operation_id
    add_foreign_key :accounts, :budgets, on_delete: :cascade
    add_foreign_key :accounts, :jobs, on_delete: :cascade
    add_foreign_key :accounts, :operations, on_delete: :cascade
    add_foreign_key :accounts, :users, on_delete: :cascade

    # allowable_field_types
    # already indexed on field_type_id
    # already indexed on sample_type_id
    # already indexed on object_type_id
    add_foreign_key :allowable_field_types, :field_types, on_delete: :cascade
    add_foreign_key :allowable_field_types, :sample_types, on_delete: :cascade
    add_foreign_key :allowable_field_types, :object_types, on_delete: :cascade

    # data_associations
    # already indexed on upload_id
    add_index       :data_associations, [ :parent_class, :parent_id ]
    add_foreign_key :data_associations, :uploads, on_delete: :cascade

    # field_types
    # remove index on parent_id (index_field_types_on_sample_type_id)
    remove_index    :field_types, name: "index_field_types_on_sample_type_id"
    add_index       :field_types, [ :parent_class, :parent_id ]

    # field_values
    # already indexed on field_type_id
    # already indexed on allowable_field_type_id
    # remove index on parent_id (index_field_values_on_sample_id)
    remove_index    :field_values, name: "index_field_values_on_sample_id"
    add_index       :field_values, [ :parent_class, :parent_id ]
    add_foreign_key :field_values, :items, column: "child_item_id", on_delete: :cascade
    add_foreign_key :field_values, :samples, column: "child_sample_id", on_delete: :cascade
    add_foreign_key :field_values, :allowable_field_types, on_delete: :cascade
    add_foreign_key :field_values, :field_types, on_delete: :cascade

    # invoices
    add_index       :invoices, :user_id
    add_index       :invoices, :budget_id
    add_foreign_key :invoices, :users, on_delete: :cascade
    add_foreign_key :invoices, :budgets, on_delete: :cascade

    # items
    # already indexed on object_type_id
    add_index       :items, :sample_id
    add_index       :items, :locator_id
    add_foreign_key :items, :samples, on_delete: :cascade
    add_foreign_key :items, :locators, on_delete: :cascade
    add_foreign_key :items, :object_types, on_delete: :cascade

    # job_associations
    add_index       :job_associations, :job_id
    add_index       :job_associations, :operation_id
    add_foreign_key :job_associations, :jobs, on_delete: :cascade
    add_foreign_key :job_associations, :operations, on_delete: :cascade

    # jobs
    ### TODO: WHAT IS METACOL ID
    ### TODO: WHAT IS SUCCESSOR ID
    add_index       :jobs, :user_id
    add_index       :jobs, :group_id
    add_foreign_key :jobs, :users
    add_foreign_key :jobs, :groups

    # locators
    add_index       :locators, :item_id
    add_index       :locators, :wizard_id
    add_foreign_key :locators, :items, on_delete: :cascade
    add_foreign_key :locators, :wizards, on_delete: :cascade

    # logs
    add_index       :logs, :job_id
    add_index       :logs, :user_id
    add_foreign_key :logs, :jobs, on_delete: :cascade
    add_foreign_key :logs, :users, on_delete: :cascade

    # memberships
    add_index       :memberships, :group_id
    add_index       :memberships, :user_id
    add_foreign_key :memberships, :groups, on_delete: :cascade
    add_foreign_key :memberships, :users, on_delete: :cascade

    # operation_types
    # already indexed on [ :catgory, :name ]

    # operations
    ### TODO: WHAT IS PARENT_ID
    # already indexed on operation_type_id
    # already indexed on user_id
    add_foreign_key :operations, :operation_types
    add_foreign_key :operations, :users

    # part_associations
    # already indexed on [ :collection_id, :row, :column ]
    add_index       :part_associations, :part_id
    add_foreign_key :part_associations, :items, column: "collection_id", on_delete: :cascade
    add_foreign_key :part_associations, :items, column: "part_id", on_delete: :cascade

    # plan_associations
    # already indexed on operation_id
    # already indexed on plan_id
    add_foreign_key :plan_associations, :operations, on_delete: :cascade
    add_foreign_key :plan_associations, :plans, on_delete: :cascade

    # plans
    # already indexed on user_id
    add_index       :plans, :budget_id
    add_foreign_key :plans, :budgets, on_delete: :cascade
    add_foreign_key :plans, :users, on_delete: :cascade

    # samples
    add_index       :samples, :sample_type_id
    add_index       :samples, :user_id
    add_foreign_key :samples, :sample_types, on_delete: :cascade
    add_foreign_key :samples, :users, on_delete: :cascade

    # timings
    add_index       :timings, [ :parent_class, :parent_id ]

    # uploads
    add_index       :uploads, :job_id
    add_foreign_key :uploads, :jobs, on_delete: :cascade

    # users
    # already indexed on login
    # already indexed on remember_token

    # user_budget_associations
    add_index       :user_budget_associations, :budget_id
    add_index       :user_budget_associations, :user_id
    add_foreign_key :user_budget_associations, :budgets, on_delete: :cascade
    add_foreign_key :user_budget_associations, :users, on_delete: :cascade

    # wires
    add_index       :wires, :from_id
    add_index       :wires, :to_id
    add_foreign_key :wires, :field_values, column: "from_id", on_delete: :cascade
    add_foreign_key :wires, :field_values, column: "to_id", on_delete: :cascade

  end
end
