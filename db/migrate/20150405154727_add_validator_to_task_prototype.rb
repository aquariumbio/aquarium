# typed: false
class AddValidatorToTaskPrototype < ActiveRecord::Migration
  def change
    add_column :task_prototypes, :validator, :string
  end
end
