

class TwoNewFields < ActiveRecord::Migration
  def change
    add_column :sample_types, :field5name, :string
    add_column :sample_types, :field5type, :string
    add_column :samples, :field5, :string
    add_column :sample_types, :field6name, :string
    add_column :sample_types, :field6type, :string
    add_column :samples, :field6, :string
  end
end
