class ChangeUserToUserIDinLog < ActiveRecord::Migration
  def change
    rename_column :logs, :user, :user_id
  end
end
