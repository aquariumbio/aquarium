class AddImageToObjectType < ActiveRecord::Migration
  def change
    add_attachment :object_types, :image
  end
end
