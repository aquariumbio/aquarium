# typed: false
class AddMessageToMetacols < ActiveRecord::Migration
  def change
    add_column :metacols, :message, :text
  end
end
