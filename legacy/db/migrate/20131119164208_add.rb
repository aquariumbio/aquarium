# typed: false
class Add < ActiveRecord::Migration
  def change
    add_column :jobs, :metacol_id, :integer  
  end
end
