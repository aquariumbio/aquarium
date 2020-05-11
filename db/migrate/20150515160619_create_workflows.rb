# typed: false
class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :name
      t.text :specification

      t.timestamps
    end
  end
end
