class AddParentIdToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :parent_id, :integer 
  end
end
