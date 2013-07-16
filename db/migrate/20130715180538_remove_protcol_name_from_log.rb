class RemoveProtcolNameFromLog < ActiveRecord::Migration
  def up
    remove_column :logs, :protcol_name
  end

  def down
    add_column :logs, :protcol_name, :string
  end
end
