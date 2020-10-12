# typed: false
class CreateUserBudgetAssociations < ActiveRecord::Migration
  def change
    create_table :user_budget_associations do |t|
      t.integer :user_id
      t.integer :budget_id
      t.float :quota
      t.boolean :disabled

      t.timestamps
    end
  end
end
