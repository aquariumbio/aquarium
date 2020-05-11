# typed: false
class AddUserIdToWorkflowThread < ActiveRecord::Migration
  def change
    add_column :workflow_threads, :user_id, :integer
  end
end
