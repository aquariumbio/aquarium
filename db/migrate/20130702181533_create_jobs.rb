class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :user_id
      t.string :sha
      t.text :arguments
      t.text :state

      t.timestamps
    end
  end
end
