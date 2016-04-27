class RenameAccountLogAssociation < ActiveRecord::Migration
  def up
    rename_table :account_log_associations, :account_logs
  end

  def down
    rename_table :account_logs, :account_log_associations   
  end
end
