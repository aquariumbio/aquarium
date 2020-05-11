# typed: false
class AddNotesAndStatusToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :status, :string
    add_column :invoices, :notes, :text
  end
end
