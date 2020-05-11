# typed: false
#
# This migration is associated with the dead code removal branch and deletes all the old Aquarium 1.0
# models, views, library code, etc. 
#

class DeadCodeRemoval < ActiveRecord::Migration

  def change

    # Get rid of all tasks stuff
    drop_table :tasks if table_exists? :tasks
    drop_table :task_notifications if table_exists? :task_notifications
    drop_table :task_prototypes if table_exists? :task_prototypes

    if column_exists? :account_logs, :task_id
      remove_column :account_logs, :task_id
    end

    if column_exists? :accounts, :task_id
      remove_column :accounts, :task_id
    end

    # Note: task_id in post_associations and touches will be dropped later

    # Git rid of git related stuff
    drop_table :blobs if table_exists? :blobs

    if column_exists? :jobs, :sha
      remove_column :jobs, :sha
    end    

    # delete metacols
    drop_table :metacols if table_exists? :metacols

    # delete cart_items
    drop_table :cart_items if table_exists? :cart_items

    # delete takes and touches
    drop_table :takes if table_exists? :takes 
    drop_table :touches if table_exists? :touches  

    # delete posts and post_associations
    drop_table :posts if table_exists? :posts 
    drop_table :post_associations if table_exists? :post_associations      

    # drop workflow stuff
    drop_table :workflows if table_exists? :workflows 
    drop_table :workflow_processes if table_exists? :workflow_processes
    drop_table :workflow_threads if table_exists? :workflow_threads
    drop_table :workflow_associations if table_exists? :workflow_associations

  end

end
