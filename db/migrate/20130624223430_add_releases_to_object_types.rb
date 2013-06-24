class AddReleasesToObjectTypes < ActiveRecord::Migration
  def change
    add_column :object_types, :release_method, :string, :default => 'return'
    add_column :object_types, :release_description, :text, :default => 'Replace this item'
  end
end
