class CreateObjectTypes < ActiveRecord::Migration
  def change
    create_table :object_types do |t|
      t.string :name
      t.string :description
      t.integer :min
      t.integer :max
      t.string :handler
      t.text :safety
      t.text :cleanup
      t.text :data
      t.text :vendor

      t.timestamps
    end
  end
end
