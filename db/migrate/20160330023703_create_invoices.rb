class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :year
      t.integer :month
      t.integer :budget_id
      t.integer :user_id

      t.timestamps
    end
  end
end
