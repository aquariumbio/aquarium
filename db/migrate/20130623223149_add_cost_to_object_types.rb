class AddCostToObjectTypes < ActiveRecord::Migration
  def change
    add_column :object_types, :cost, :float
  end
end
