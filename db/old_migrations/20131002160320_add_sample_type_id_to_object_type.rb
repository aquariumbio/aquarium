class AddSampleTypeIdToObjectType < ActiveRecord::Migration
  def change
    add_column :object_types, :sample_type_id, :integer
    add_column :items, :sample_id, :integer
  end
end
