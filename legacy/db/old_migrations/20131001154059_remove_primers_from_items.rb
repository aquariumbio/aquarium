# typed: false
# frozen_string_literal: true

class RemovePrimersFromItems < ActiveRecord::Migration
  def up
    remove_column :items, :table
    remove_column :items, :table_entry_id
  end

  def down; end
end
