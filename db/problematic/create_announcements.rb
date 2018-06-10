

class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :title
      t.text :message
      t.boolean :active

      t.timestamps
    end
  end
end
