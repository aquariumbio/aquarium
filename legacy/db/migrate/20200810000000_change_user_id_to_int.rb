# typed: false
class ChangeUserIdToInt < ActiveRecord::Migration

  def change

    # jobs
    change_column   :jobs, :user_id, :integer

    # logs
    change_column   :logs, :user_id, :integer

  end
end
