class ChangeOwnerToUserId < ActiveRecord::Migration
  def change
    remove_column :samples, :owner
    add_column :samples, :user_id, :integer
  end
end
