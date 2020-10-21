class Role < ActiveRecord::Base

  # usage   role_ids[<id>]
  # usage   role_ids.key(<name>)
  def self.role_ids(clear_cache = false)
    Rails.cache.delete 'role_ids' if clear_cache
    Rails.cache.fetch 'role_ids' do
      hash={}
      sql = "select * from roles order by sort, id"
      (Role.find_by_sql sql).each do |r|
        hash=hash.update({r.id => r.name})
      end
      hash
    end
  end

end
