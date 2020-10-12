# typed: false
class AddPreferredToFieldType < ActiveRecord::Migration
  def change
    add_column :field_types, :preferred_operation_type_id, :integer
    add_column :field_types, :preferred_field_type_id, :integer    
  end
end
