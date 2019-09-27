# frozen_string_literal: true

class AddDataToItem < ActiveRecord::Migration
  def change
    add_column :items, :data, :string
  end
end
