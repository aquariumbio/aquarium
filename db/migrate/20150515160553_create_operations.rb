class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.string :name
      t.string :protocol_path
      t.text :specification

      t.timestamps
    end
  end
end
