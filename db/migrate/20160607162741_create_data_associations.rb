class CreateDataAssociations < ActiveRecord::Migration
  def change
    create_table :data_associations do |t|
      t.integer :parent_id
      t.string :parent_class
      t.string :key
      t.references :upload
      t.text :object

      t.timestamps
    end
    add_index :data_associations, :upload_id
  end
end
