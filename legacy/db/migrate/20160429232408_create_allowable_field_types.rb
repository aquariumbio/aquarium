# typed: false
class CreateAllowableFieldTypes < ActiveRecord::Migration
  def change
    create_table :allowable_field_types do |t|
      t.references :field_type
      t.references :sample_type
      t.references :object_type

      t.timestamps
    end
    add_index :allowable_field_types, :field_type_id
    add_index :allowable_field_types, :sample_type_id
    add_index :allowable_field_types, :object_type_id
  end
end
