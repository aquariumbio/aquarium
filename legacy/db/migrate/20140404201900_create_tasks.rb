# typed: false
class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :specification
      t.string :status

      t.timestamps
    end
  end
end
