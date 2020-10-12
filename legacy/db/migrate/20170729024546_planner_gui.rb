# typed: false
class PlannerGui < ActiveRecord::Migration

  def change

    add_column :plans, :name, :string
    add_column :plans, :status, :string 
    add_column :plans, :cost_limit, :float

    add_column :operations, :x, :float
    add_column :operations, :y, :float      

  end

end
