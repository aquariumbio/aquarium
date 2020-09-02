# typed: false
class AddCostToTaskPrototype < ActiveRecord::Migration
  def change
    add_column :task_prototypes, :cost, :float, :default => 1.00
  end
end
