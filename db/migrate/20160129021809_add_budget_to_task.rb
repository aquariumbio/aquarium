class AddBudgetToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :budget_id, :integer
  end
end
