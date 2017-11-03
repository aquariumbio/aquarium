class AddUserToCode < ActiveRecord::Migration
  def change
    add_column :codes, :user_id, :integer
    remove_column :codes, :child_id    
  end
end
