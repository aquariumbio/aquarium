# typed: false
class CreateFolderContents < ActiveRecord::Migration
  def change
    create_table :folder_contents do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :sample_id

      t.timestamps
    end
  end
end
