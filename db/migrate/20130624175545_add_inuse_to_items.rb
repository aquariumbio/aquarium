class AddInuseToItems < ActiveRecord::Migration
  def change
    add_column :items, :inuse, :integer, :default => 0
  end
end
