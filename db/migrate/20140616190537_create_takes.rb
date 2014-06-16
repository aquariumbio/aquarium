class CreateTakes < ActiveRecord::Migration
  def change
    create_table :takes do |t|
      t.integer :item_id
      t.integer :job_id

      t.timestamps
    end
  end
end
