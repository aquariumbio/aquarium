

class AddJobIdToBlobs < ActiveRecord::Migration
  def change
    add_column :blobs, :job_id, :integer
  end
end
