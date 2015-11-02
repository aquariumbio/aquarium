class AddDataToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :data, :text 
    add_column :sample_types, :datatype, :text     
  end
end
