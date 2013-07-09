class CreateBlobs < ActiveRecord::Migration
  def change
    create_table :blobs do |t|
      t.string :sha
      t.string :path
      t.text :xml

      t.timestamps
    end
  end
end
