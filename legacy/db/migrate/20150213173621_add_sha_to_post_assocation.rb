# typed: false
class AddShaToPostAssocation < ActiveRecord::Migration
  def change
    add_column :post_associations, :sha, :string 
  end
end
