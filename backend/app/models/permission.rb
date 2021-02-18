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

  # Any permission
  #
  # @return 0
  def self.any
    0
  end

  # Cache admin id.
  #
  # @return admin_id
  def self.admin_id(clear_cache = false)
    Rails.cache.delete 'admin_id' if clear_cache
    Rails.cache.fetch 'admin_id' do
      Permission.permission_ids.key('admin')
    end
  end

  # Cache retired id.
  #
  # @return retired_id
  def self.retired_id(clear_cache = false)
    Rails.cache.delete 'retired_id' if clear_cache
    Rails.cache.fetch 'retired_id' do
      Permission.permission_ids.key('retired')
    end
  end


  # Check whether permission_ids has the specific permission permission_id. Used to gate access to the site.
  # permission_id ==  <id for "any">:    true if anything and not retired
  # permission_id ==  <id for admin>:    true if admin and not retired
  # permission_id ==  <id for ___>:      true if ( ___  or admin ) and not retired
  # permission_id ==  <id for retired>:  not supported
  #                                      (technically it will return "false" if retired and return "true" if admin and not retired,
  #                                       which is kind of weird, but it doesn't really matter because it is not used)
  #
  # @param permission_ids [Str] the permission_ids beging checked
  # @param permission_id [Int] the permission_id for which to check
  # @return whether permission_ids has permission for permission_id
  def self.ok?(permission_ids, permission_id)
    # return false if retired
    return false if permission_ids.index(".#{Permission.permission_ids.key('retired')}.")

    # return true if permission_id == 0
    return true if permission_id == Permission.any

    # Check <permission_id> and check "admin"
    permission_ids.index(".#{permission_id}.") or permission_ids.index(".#{Permission.permission_ids.key('admin')}.")
  end
end
