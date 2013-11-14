class AddScheduleingToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :group_id, :integer
    add_column :jobs, :submitted_by, :integer
    add_column :jobs, :desired_start_time, :datetime
    add_column :jobs, :desired_stop_time, :datetime
  end
end
