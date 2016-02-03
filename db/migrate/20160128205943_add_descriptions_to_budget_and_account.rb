class AddDescriptionsToBudgetAndAccount < ActiveRecord::Migration
  def change
    add_column :budgets, :description, :text
    add_column :accounts, :description, :text    
  end
end
 