class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.integer :job_id
      t.attachment :upload

      t.timestamps
    end
  end
end
