class AddUserIdToParemeters < ActiveRecord::Migration
  def change
    add_column :parameters, :user_id, :integer
  end
end
