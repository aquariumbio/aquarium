# typed: false
class AddNameIndexToOperationType < ActiveRecord::Migration
  def change
    add_index :operation_types, [:category, :name], unique: true
  end
end
