# typed: false
# frozen_string_literal: true

class AlterImageHandlingInObjectType < ActiveRecord::Migration

  def change
    remove_column :object_types, :image_file_name
    remove_column :object_types, :image_content_type
    remove_column :object_types, :image_file_size
    remove_column :object_types, :image_updated_at
    add_column :object_types, :image, :string
  end

end
