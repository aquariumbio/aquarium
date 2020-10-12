# typed: false
class AddStatusOptionsToTaskPrototype < ActiveRecord::Migration
  def change
    add_column :task_prototypes, :status_options, :string
  end
end
