class DropStaticFields < ActiveRecord::Migration
  def change
    (1..8).each do |i|
      remove_column :sample_types, "field#{i}name".to_sym
      remove_column :sample_types, "field#{i}type".to_sym
      remove_column :samples, "field#{i}".to_sym    
    end
  end
end
