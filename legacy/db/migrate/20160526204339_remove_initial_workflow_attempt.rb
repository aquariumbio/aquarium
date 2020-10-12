# typed: false
class RemoveInitialWorkflowAttempt < ActiveRecord::Migration
  def change
    drop_table :operations
    drop_table :workflows
    drop_table :workflow_associations
    drop_table :workflow_threads
    drop_table :workflow_processes
    drop_table :folders
    drop_table :folder_contents
    remove_column :jobs, :workflow_process_id
  end
end
