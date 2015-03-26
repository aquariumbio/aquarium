class CreateTaskNotifications < ActiveRecord::Migration
  def change
    create_table :task_notifications do |t|
      t.text :content
      t.integer :task_id
      t.integer :job_id
      t.boolean :read

      t.timestamps
    end
  end
end
