class AddTableToItem < ActiveRecord::Migration
  def change
    add_column :items, :table, :string
    add_column :items, :table_entry_id, :integer
  end
end
