class RemoveProtocolShaFromLog < ActiveRecord::Migration
  def up
    remove_column :logs, :protocol_sha
  end

  def down
    add_column :logs, :protocol_sha, :string
  end
end
