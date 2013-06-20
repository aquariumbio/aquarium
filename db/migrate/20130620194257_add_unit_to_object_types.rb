class AddUnitToObjectTypes < ActiveRecord::Migration
  def change
    add_column :object_types, :unit, :string
  end
end
