# typed: false
class DropCollection < ActiveRecord::Migration
  def change
  	drop_table :collections
 	drop_table :parts
 	remove_column :items, :collection_id
  end
end
