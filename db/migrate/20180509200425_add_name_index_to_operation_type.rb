class AddNameIndexToOperationType < ActiveRecord::Migration
  def change
    add_index :operation_types, :name, unique: true
  end
end
