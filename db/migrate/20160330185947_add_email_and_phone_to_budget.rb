class AddEmailAndPhoneToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :email, :string
    add_column :budgets, :phone, :string
  end
end
