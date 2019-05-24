# frozen_string_literal: true

class DropPrimers < ActiveRecord::Migration
  def up
    drop_table :primers
  end

  def down; end
end
