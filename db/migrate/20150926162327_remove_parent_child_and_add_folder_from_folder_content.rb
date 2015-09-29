class RemoveParentChildAndAddFolderFromFolderContent < ActiveRecord::Migration
  def change
    add_column :folder_contents, :folder_id, :integer 
    remove_column :folder_contents, :parent_id, :integer 
    remove_column :folder_contents, :child_id, :integer     
  end
end
