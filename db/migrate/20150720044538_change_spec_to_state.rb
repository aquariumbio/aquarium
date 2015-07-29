class ChangeSpecToState < ActiveRecord::Migration
  def change
    rename_column :workflow_processes, :specification, :state
  end
end
