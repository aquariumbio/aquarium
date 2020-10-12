# typed: false
class AddDescriptionToWizard < ActiveRecord::Migration
  def change
    add_column :wizards, :description, :string    
  end
end
