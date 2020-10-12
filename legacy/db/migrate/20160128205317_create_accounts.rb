# typed: false
class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :type
      t.boolean :credit
      t.float :amount
      t.references :user
      t.references :budget
      t.string :category
      t.references :task
      t.references :job

      t.timestamps
    end
    add_index :accounts, :user_id
    add_index :accounts, :budget_id
    add_index :accounts, :task_id
    add_index :accounts, :job_id
  end
end
