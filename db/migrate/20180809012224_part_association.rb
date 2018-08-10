class PartAssociation < ActiveRecord::Migration
  def change
    create_table :part_associations do |t|
      t.integer :part_id
      t.integer :collection_id
      t.integer :row
      t.integer :column
      t.timestamps
    end
    add_index(:part_associations, [:collection_id, :row, :column], unique: true)
  end
end
