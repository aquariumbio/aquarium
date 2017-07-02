class DropJobFromOperation < ActiveRecord::Migration
  def change
    remove_column :operations, :job_id
  end
end
