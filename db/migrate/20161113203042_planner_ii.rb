# typed: false
class PlannerIi < ActiveRecord::Migration
  
  def change
    add_column :field_types, :routing, :string    
  end

end
