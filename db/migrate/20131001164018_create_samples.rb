class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.string :name
      t.integer :sample_type_id
      t.string :owner
      t.string :project
      t.string :field1
      t.string :field2
      t.string :field3
      t.string :field4

      t.timestamps
    end
  end
end
