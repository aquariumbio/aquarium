class AddDirToBlobs < ActiveRecord::Migration
  def change
    add_column :blobs, :dir, :text
  end
end
