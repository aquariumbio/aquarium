# typed: false
class CreateTaskPrototypes < ActiveRecord::Migration
  def change
    create_table :task_prototypes do |t|
      t.string :name
      t.string :description
      t.string :prototype

      t.timestamps
    end
  end
end
