# typed: false
class CreateLocators < ActiveRecord::Migration
  def change
    create_table :locators do |t|
      t.integer :wizard_id
      t.integer :item_id
      t.integer :number

      t.timestamps
    end
  end
end
