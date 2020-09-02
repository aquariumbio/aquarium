# typed: false
class AddLocatorIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :locator_id, :integer
  end
end
