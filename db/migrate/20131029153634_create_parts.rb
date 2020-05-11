# typed: false
class CreateParts < ActiveRecord::Migration
  def change
    create_table :parts do |t|
      t.integer :collection_id
      t.integer :item_id
      t.integer :row
      t.integer :column

      t.timestamps
    end
  end
end
