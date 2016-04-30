class ChangeFieldTypeIdToName < ActiveRecord::Migration
  def change
    remove_column :field_values, :field_type_id
    add_column :field_values, :name, :string
  end
end
