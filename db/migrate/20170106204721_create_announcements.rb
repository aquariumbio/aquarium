class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.text :message
      t.boolean :active

      t.timestamps
    end
  end
end
