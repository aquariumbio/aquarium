# typed: false
class RemoveParentChildAndAddFolderFromFolderContent < ActiveRecord::Migration
  def change
    begin
      add_column :folder_contents, :folder_id, :integer 
    rescue 
      puts "Column folder_id already added to folder_contents"
    end
    remove_column :folder_contents, :parent_id
    remove_column :folder_contents, :child_id
  end
end
