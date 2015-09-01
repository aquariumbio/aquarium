class AddWorkflowProcessIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :workflow_process_id, :integer    
  end
end
