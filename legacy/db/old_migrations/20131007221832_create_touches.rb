# typed: false
# frozen_string_literal: true

class CreateTouches < ActiveRecord::Migration
  def change
    create_table :touches do |t|
      t.references :item
      t.references :job

      t.timestamps
    end
    add_index :touches, :item_id
    add_index :touches, :job_id
  end
end
