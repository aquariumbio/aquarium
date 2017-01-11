class AddTitleToAnnouncements < ActiveRecord::Migration
  def change
  	add_column :announcements, :title, :string
  end
end
