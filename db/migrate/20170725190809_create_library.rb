class CreateLibrary < ActiveRecord::Migration
  def change
    create_table :libraries do |t|
      t.string :name
      t.string :category
      t.timestamps
    end    
  end
end
