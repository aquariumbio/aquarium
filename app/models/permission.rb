# frozen_string_literal: true

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

  # Cache manage id.
  #
  # @return manage_id
  def self.manage_id(clear_cache = false)
    Rails.cache.delete 'manage_id' if clear_cache
    Rails.cache.fetch 'manage_id' do
      Permission.permission_ids.key('manage')
    end
  end

  # Cache run id.
  #
  # @return run_id
  def self.run_id(clear_cache = false)
    Rails.cache.delete 'run_id' if clear_cache
    Rails.cache.fetch 'run_id' do
      Permission.permission_ids.key('run')
    end
  end

  # Cache design id.
  #
  # @return design_id
  def self.design_id(clear_cache = false)
    Rails.cache.delete 'design_id' if clear_cache
    Rails.cache.fetch 'design_id' do
      Permission.permission_ids.key('design')
    end
  end

  # Cache develop id.
  #
  # @return develop_id
  def self.develop_id(clear_cache = false)
    Rails.cache.delete 'develop_id' if clear_cache
    Rails.cache.fetch 'develop_id' do
      Permission.permission_ids.key('develop')
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

end
