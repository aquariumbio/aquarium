# frozen_string_literal: true

class RemoveAnotherDefaultValueFromObjectType < ActiveRecord::Migration
  def up
    change_column_default(:object_types, :release_description, nil)
  end

  def down; end
end
