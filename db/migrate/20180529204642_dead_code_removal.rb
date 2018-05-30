class DeadCodeRemoval < ActiveRecord::Migration

  def change

    # Get rid of all tasks stuff
    drop_table :tasks, if_exists: true
    drop_table :task_notification, if_exists: true
    drop_table :task_prototype, if_exists: true

    if column_exists? :account_logs, :task_id
      remove_column :accounts_logs, :task_id
      remove_index :accounts_logs, :task_id
    end

    if column_exists? :accounts, :task_id
      remove_column :accounts, :task_id
      remove_index :accounts, :task_id
    end

    # Note: task_id in post_associations and touches will be dropped later

    # Git rid of git related stuff
    drop_table :blobs, if_exists: true
    
    if column_exists? :jobs, :sha
      remove_column :jobs, :sha
    end    

  end

end
