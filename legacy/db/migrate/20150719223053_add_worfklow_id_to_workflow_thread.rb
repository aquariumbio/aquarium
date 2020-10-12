# typed: false
class AddWorfklowIdToWorkflowThread < ActiveRecord::Migration
  def change
    add_column :workflow_threads, :workflow_id, :integer
  end
end
