# typed: false
class Roles < ActiveRecord::Migration[4.2]

  def change
    add_column :users, :role_ids, :string, :default => "."

    # CREATE ROLES TABLE
    create_table :roles do |t|
      t.string :name, :default => '', :unique => true
      t.integer :sort

      t.timestamps
    end

    change_column_null :roles, :name, false
    add_index :roles, :name, unique: true

    # POPULATE ROLES TABLE
    execute <<-SQL
      INSERT INTO `roles`(`id`,`name`,`sort`,`created_at`,`updated_at`) VALUES
      ( '1', 'admin', '1', '2020-01-01 00:00:00', '2020-01-01 00:00:00' ),
      ( '2', 'manage', '2', '2020-01-01 00:00:00', '2020-01-01 00:00:00' ),
      ( '3', 'run', '3', '2020-01-01 00:00:00', '2020-01-01 00:00:00' ),
      ( '4', 'design', '4', '2020-01-01 00:00:00', '2020-01-01 00:00:00' ),
      ( '5', 'develop', '5', '2020-01-01 00:00:00', '2020-01-01 00:00:00' ),
      ( '6', 'retired', '6', '2020-01-01 00:00:00', '2020-01-01 00:00:00' );
    SQL

    # CREATE USER_TOKENS TABLE IN SQL TO SUPPORT THE COMPOSITE KEY
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
