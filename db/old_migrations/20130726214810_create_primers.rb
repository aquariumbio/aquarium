# frozen_string_literal: true

class CreatePrimers < ActiveRecord::Migration
  def change
    create_table :primers do |t|
      t.string :description
      t.string :annealing
      t.string :overhang
      t.float :tm
      t.text :notes
      t.integer :project
      t.integer :owner

      t.timestamps
    end
  end
end
