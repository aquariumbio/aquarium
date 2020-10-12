# typed: false
class CreateAccountLogAssociations < ActiveRecord::Migration
  def change
    create_table :account_log_associations do |t|
      t.integer :row1
      t.integer :row2
      t.references :task
      t.references :user
      t.text :note

      t.timestamps
    end
    add_index :account_log_associations, :task_id
    add_index :account_log_associations, :user_id
  end
end
