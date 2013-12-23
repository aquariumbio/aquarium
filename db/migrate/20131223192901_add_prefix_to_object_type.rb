class AddPrefixToObjectType < ActiveRecord::Migration
  def change
    add_column :object_types, :prefix, :string
  end
end
