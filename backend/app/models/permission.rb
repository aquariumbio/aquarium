# DEFAULT PERMISSIONS
#   1 - ADMIN
#   2 - MANAGE
#   3 - RUN
#   4 - DESIGN
#   5 - DEVELOP
#   6 - RETIRED

# RETIRED AND ADMIN ARE SPECIAL CASES
#   - IF RETIRED, THEN THE USER HAS NO ACCESS AND ALL OTHER PERMISSIONS ARE IGNORED (INCLUDING ADMIN)
#   - IF ADMIN (AND NOT RETIRED), THEN THE USER HAS ACCESS TO MANAGE, RUN, DESIGN, AND DEVELOP
#     REGARDLESS OF WHETHER THE USER HAS EXPLICIT PERMISSIONS FOR THOSE ITEMS

class Permission < ActiveRecord::Base
  # usage   permission_ids[<id>]
  # usage   permission_ids.key(<name>)
  def self.permission_ids(clear_cache = false)
    Rails.cache.delete 'permission_ids' if clear_cache
    Rails.cache.fetch 'permission_ids' do
      hash = {}
      sql = 'select * from permissions order by sort, id'
      (Permission.find_by_sql sql).each do |r|
        hash = hash.update({ r.id => r.name })
      end
      hash
    end
  end
end
