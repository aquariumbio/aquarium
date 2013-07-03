class AddPathToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :path, :string
  end
end
