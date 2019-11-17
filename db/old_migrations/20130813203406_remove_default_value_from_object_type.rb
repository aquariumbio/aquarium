# frozen_string_literal: true

class RemoveDefaultValueFromObjectType < ActiveRecord::Migration
  def up
    change_column_default(:object_types, :release_method, nil)
  end

  def down; end
end
