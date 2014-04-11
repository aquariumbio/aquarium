class AddTaskIdAndMetacolIdToTouch < ActiveRecord::Migration
  def change
    add_column :touches, :task_id, :integer
    add_column :touches, :metacol_id, :integer
  end
end
