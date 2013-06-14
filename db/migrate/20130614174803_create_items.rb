class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :location
      t.integer :quantity
      t.references :object_type

      t.timestamps
    end
    add_index :items, :object_type_id
  end
end
