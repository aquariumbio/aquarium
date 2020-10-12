# typed: false
class CreateWizards < ActiveRecord::Migration
  def change
    create_table :wizards do |t|
      t.string :name
      t.string :specification

      t.timestamps
    end
  end
end
