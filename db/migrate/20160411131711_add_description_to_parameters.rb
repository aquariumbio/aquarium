class AddDescriptionToParameters < ActiveRecord::Migration
  def change
    add_column :parameters, :description, :text
  end
end
