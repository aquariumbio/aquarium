class CreateFieldTypes < ActiveRecord::Migration
  def change
    create_table :field_types do |t|
      t.references :sample_type
      t.string :name
      t.string :type
      t.string :choices
      t.boolean :array
      t.boolean :required

      t.timestamps
    end
    add_index :field_types, :sample_type_id
  end
end
