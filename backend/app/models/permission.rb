class Permission < ActiveRecord::Base

  # usage   permission_ids[<id>]
  # usage   permission_ids.key(<name>)
  def self.permission_ids(clear_cache = false)
    Rails.cache.delete 'permission_ids' if clear_cache
    Rails.cache.fetch 'permission_ids' do
      hash={}
      sql = "select * from permissions order by sort, id"
      (Permission.find_by_sql sql).each do |r|
        hash=hash.update({r.id => r.name})
      end
      hash
    end
  end

end
