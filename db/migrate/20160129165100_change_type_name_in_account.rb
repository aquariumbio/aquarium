class ChangeTypeNameInAccount < ActiveRecord::Migration
  def change
    rename_column :accounts, :type, :transaction_type
  end
end
