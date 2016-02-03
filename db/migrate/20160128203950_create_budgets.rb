class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :name
      t.float :overhead
      t.string :contact

      t.timestamps
    end
  end
end
