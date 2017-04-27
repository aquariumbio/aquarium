class AdjustAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :operation_id, :integer    
    remove_column :operations, :labor
    remove_column :operations, :materials
  end
end
