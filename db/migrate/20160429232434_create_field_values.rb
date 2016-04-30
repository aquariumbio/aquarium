class CreateFieldValues < ActiveRecord::Migration
  def change
    create_table :field_values do |t|
      t.references :sample
      t.references :field_type
      t.string :value
      t.integer :child_sample_id
      t.integer :child_item_id

      t.timestamps
    end
    add_index :field_values, :sample_id
    add_index :field_values, :field_type_id
  end
end
