class CreatePostAssociations < ActiveRecord::Migration
  def change
    create_table :post_associations do |t|
      t.integer :post_id
      t.integer :sample_id
      t.integer :item_id
      t.integer :job_id
      t.integer :task_id

      t.timestamps
    end
  end
end
