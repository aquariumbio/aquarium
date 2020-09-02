# typed: false
class AddBudgetIdToPlan < ActiveRecord::Migration
  def change 
    add_column :plans, :budget_id, :integer
  end
end
