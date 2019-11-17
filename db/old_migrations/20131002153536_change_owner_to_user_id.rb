# frozen_string_literal: true

class ChangeOwnerToUserId < ActiveRecord::Migration
  def change
    remove_column :samples, :owner, :string
    add_column :samples, :user_id, :integer
  end
end
