class AddRatesToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :labor_rate, :float
    add_column :accounts, :markup_rate, :float    
  end
end
