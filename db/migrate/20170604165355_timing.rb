class Timing < ActiveRecord::Migration
  def change
    create_table :timings do |t|
      t.integer :parent_id
      t.string :parent_class
      t.string :days
      t.integer :start
      t.integer :stop
      t.timestamps
    end
  end
end
