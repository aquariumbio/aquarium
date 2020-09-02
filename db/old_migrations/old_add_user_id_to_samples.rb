# typed: false
# frozen_string_literal: true

class AddUserIdToSamples < ActiveRecord::Migration
  def change
    add_column :samples, :user_id, :string
  end
end
