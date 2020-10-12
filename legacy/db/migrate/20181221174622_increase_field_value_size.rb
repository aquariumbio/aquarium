# typed: false
class IncreaseFieldValueSize < ActiveRecord::Migration
  def change
    change_column :field_values, :value, :text
  end
end
