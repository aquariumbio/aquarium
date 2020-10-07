class Role < ActiveRecord::Base

  # usage   role_ids[<id>]
  # usage   role_ids.key(<name>)
  def self.role_ids
#     Rails.cache.delete 'role_ids'
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
