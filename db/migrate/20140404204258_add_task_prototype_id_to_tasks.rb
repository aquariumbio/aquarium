class AddTaskPrototypeIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :task_prototype_id, :integer
  end
end
