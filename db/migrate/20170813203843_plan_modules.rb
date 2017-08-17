class PlanModules < ActiveRecord::Migration
  def change
    add_column :plans, :layout, :text
    add_column :operations, :parent_id, :integer
  end
end
