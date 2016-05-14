class AddMetacolToTaskPrototype < ActiveRecord::Migration
  def change
    add_column :task_prototypes, :metacol, :string
  end
end
