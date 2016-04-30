class ChangeTypeToFtype < ActiveRecord::Migration
  def change
    rename_column :field_types, :type, :ftype
  end
end
