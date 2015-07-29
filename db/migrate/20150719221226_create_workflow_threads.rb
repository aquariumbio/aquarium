class CreateWorkflowThreads < ActiveRecord::Migration
  def change
    create_table :workflow_threads do |t|
      t.integer :process_id
      t.text :specification

      t.timestamps
    end
  end
end
