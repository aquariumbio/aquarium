class ChangeTaskJsonToText < ActiveRecord::Migration
  def up
    change_column :task_prototypes, :prototype, :text, limit: nil
    change_column :tasks, :specification, :text, limit: nil
  end

  def down
    change_column :task_prototypes, :prototype, :string
    change_column :tasks, :specification, :string
  end
end
