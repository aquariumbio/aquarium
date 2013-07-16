class ChangeTypeToSomethingElse < ActiveRecord::Migration

  def change
    change_table :logs do |t|
      t.rename :type, :entry_type
    end
  end

end
