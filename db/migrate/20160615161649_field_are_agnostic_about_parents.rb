class FieldAreAgnosticAboutParents < ActiveRecord::Migration
  def change
    add_column    :field_types,  :parent_class, :string
    add_column    :field_values, :parent_class, :string
    rename_column :field_types,  :sample_type_id,    :parent_id
    rename_column :field_values, :sample_id,         :parent_id    
  end
end
