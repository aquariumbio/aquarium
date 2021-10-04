# typed: false
class UpdateLocatorForeignKey < ActiveRecord::Migration[4.2]
  # View used to get extended user data (including parameters)
  def change
    # Remove current foreign key
    remove_foreign_key :locators, :items

    # Add new foriegn key
    add_foreign_key :locators, :items, on_delete: :nullify rescue nil
  end
end
