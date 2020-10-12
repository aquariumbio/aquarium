# typed: false
class DropCreditFromAccount < ActiveRecord::Migration
  def change
    remove_column :accounts, :credit
  end
end
