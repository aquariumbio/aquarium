class CreateWorkflowAssociations < ActiveRecord::Migration
  def change
    create_table :workflow_associations do |t|
      t.integer :thread_id
      t.integer :process_id
      t.integer :sample_id
      t.integer :item_id

      t.timestamps
    end
  end
end
