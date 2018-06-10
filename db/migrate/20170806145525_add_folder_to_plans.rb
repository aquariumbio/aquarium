class AddFolderToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :folder, :string
  end
end
