class RemoveProtocolNameFromLog < ActiveRecord::Migration
  def up
    remove_column :logs, :protocol_name
  end

  def down
    add_column :logs, :protocol_name, :string
  end
end
