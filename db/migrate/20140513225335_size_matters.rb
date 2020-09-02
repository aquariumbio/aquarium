# typed: false
class SizeMatters < ActiveRecord::Migration
  def change
    change_column :items, :data, :text, limit: 65536
    change_column :jobs, :state, :text, limit: 4294967295 
  end
end
