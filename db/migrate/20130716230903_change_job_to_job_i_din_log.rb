class ChangeJobToJobIDinLog < ActiveRecord::Migration
  def change
    rename_column :log, :job, :job_id
  end
end
