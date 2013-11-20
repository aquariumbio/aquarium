class CreateMetacols < ActiveRecord::Migration
  def change
    create_table :metacols do |t|
      t.string :path
      t.string :sha
      t.text :state
      t.integer :user_id
      t.string :status

      t.timestamps
    end
  end
end
