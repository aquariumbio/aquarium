class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :job
      t.string :protocol_sha
      t.string :protcol_name
      t.string :user
      t.string :type
      t.text :data

      t.timestamps
    end
  end
end
