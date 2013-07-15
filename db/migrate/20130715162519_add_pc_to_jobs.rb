class AddPcToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :pc, :integer
  end
end
