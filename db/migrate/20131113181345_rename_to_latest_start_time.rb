class RenameToLatestStartTime < ActiveRecord::Migration
  def change
    rename_column :jobs, :desired_stop_time, :latest_start_time
  end
end
