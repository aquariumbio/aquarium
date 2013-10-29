class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
      t.string :project
      t.integer :object_type_id
      t.integer :rows
      t.integer :columns

      t.timestamps
    end
  end
end
