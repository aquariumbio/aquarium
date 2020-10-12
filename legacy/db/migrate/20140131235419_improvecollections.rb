# typed: false
class Improvecollections < ActiveRecord::Migration
  def change
    remove_column :parts, :item_id
    add_column :parts, :item_id1, :integer
    add_column :parts, :item_id2, :integer
    add_column :parts, :item_id3, :integer
    add_column :parts, :item_id4, :integer
    add_column :parts, :data, :string
    add_column :collections, :location, :string
    add_column :collections, :description, :string
    add_column :items, :collection_id, :integer
  end
end
