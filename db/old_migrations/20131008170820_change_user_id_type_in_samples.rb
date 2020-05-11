# typed: false
# frozen_string_literal: true

class ChangeUserIdTypeInSamples < ActiveRecord::Migration
  def change
    remove_column :samples, :user_id
    add_column :samples, :user_id, :integer
  end
end
