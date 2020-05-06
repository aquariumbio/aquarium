# typed: false
class CreateAnemoneWorker < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :name
      t.string :message
      t.string :status
      t.timestamps
    end
  end
end
