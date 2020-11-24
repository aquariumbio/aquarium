# frozen_string_literal: true

# Default permissions
#   1 - admin
#   2 - manage
#   3 - run
#   4 - design
#   5 - develop
#   6 - retired

# Retired and admin are special cases
#   - If retired, then the user has no access and all other permissions are ignored (including admin)
#   - If admin (and not retired), then the user has access to manage, run, design, and develop
#     Regardless of whether the user has explicit permissions for those items

# permissions table
class Permission < ActiveRecord::Base
  # Cache and return the list of permissions.
  #
  # @param clear_cache [Boolean] true to clear the cache
  #
  # @return permissions
  def self.permission_ids(clear_cache = false)
    Rails.cache.delete 'permission_ids' if clear_cache
    Rails.cache.fetch 'permission_ids' do
      hash = {}
      sql = 'select * from permissions order by sort, id'
      (Permission.find_by_sql sql).each do |r|
        hash.update({ r.id => r.name })
      end
      hash
    end
  end
end
