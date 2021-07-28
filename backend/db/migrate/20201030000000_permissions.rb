# typed: false
class Permissions < ActiveRecord::Migration[4.2]
  def change
    unless column_exists? :users, :permission_ids
      add_column :users, :permission_ids, :string, :default => "."
    end

    # CREATE ROLES TABLE
    unless table_exists?(:permissions)
      create_table :permissions do |t|
        t.string :name, :default => '', :unique => true
        t.integer :sort

        t.timestamps
      end
    end

    change_column_null :permissions, :name, false
    add_index :permissions, :name, unique: true if !index_exists?(:permissions, :name)

    # POPULATE ROLES TABLE
      Permission.find_or_create_by( id: 1, name: 'admin', sort: 1 )
      Permission.find_or_create_by( id: 2, name: 'manage',  sort: 2 )
      Permission.find_or_create_by( id: 3, name: 'run',     sort: 3 )
      Permission.find_or_create_by( id: 4, name: 'design',  sort: 4 )
      Permission.find_or_create_by( id: 5, name: 'develop', sort: 5 )
      Permission.find_or_create_by( id: 6, name: 'retired', sort: 6 )

    # CREATE USER_TOKENS TABLE IN SQL TO SUPPORT THE COMPOSITE KEY
    unless table_exists?(:permissions)
      execute <<-SQL
        CREATE TABLE `user_tokens`(
          `user_id` Int( 0 ) NOT NULL,
          `token` VarChar( 128 ) NOT NULL,
          `created_at` DateTime NOT NULL,
          `updated_at` DateTime NOT NULL,
          `ip` VarChar( 18 ) NOT NULL,
          `timenow` DateTime NOT NULL,
          PRIMARY KEY ( `ip`, `token` ) );
      SQL

      add_index       :user_tokens, :user_id                     if !index_exists?(:plans, :budget_id)
      add_foreign_key :user_tokens, :users, on_delete: :cascade  rescue nil
    end
  end
end

