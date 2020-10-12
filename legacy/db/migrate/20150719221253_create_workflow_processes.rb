# typed: false
class CreateWorkflowProcesses < ActiveRecord::Migration
  def change
    create_table :workflow_processes do |t|
      t.integer :workflow_id
      t.text :specification

      t.timestamps
    end
  end
end
