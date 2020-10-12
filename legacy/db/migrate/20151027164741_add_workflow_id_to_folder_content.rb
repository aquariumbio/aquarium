# typed: false
class AddWorkflowIdToFolderContent < ActiveRecord::Migration
  def change
    add_column :folder_contents, :workflow_id, :integer 
  end
end
