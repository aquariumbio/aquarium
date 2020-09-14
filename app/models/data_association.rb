# typed: false
# frozen_string_literal: true

# @api krill
class DataAssociation < ApplicationRecord

  belongs_to :upload
  attr_accessible :parent_class, :key, :object, :parent_id, :upload_id

  def full_object
    HashWithIndifferentAccess.new(JSON.parse(object, symbolize_names: true))
  rescue StandardError
    HashWithIndifferentAccess.new
  end

  def value
    h = full_object
    h[h.keys.first]
  end

  def as_json(_options = {})
    result = super(include: :upload)
    result = result.merge url: upload.url if upload
    result
  end

  def self.find_parent(parent_class, parent_id)
    Object.const_get(parent_class).find(parent_id)
  end

  def may_delete(user)
    parent = DataAssociation.find_parent(parent_class, parent_id)
    puts "Class = #{parent_class}"
    return parent.sample && parent.sample.user_id = user.id if parent_class == 'Item'
    return user.admin? if parent_class == 'Collection' # since collections are managed by admins?
    return true if parent_class == 'Operation' # since operations don't yet have owners (actually they do now, so this should be fixed)
    return true if parent_class == 'Plan' # plans don't have owners yet either
    return true if parent_class == 'OperationType' # operation types don't have owners yet either
  end

  # Creates new association for the object identified by parent class and id
  #
  def self.create_from(parent_id:, parent_class:, key:, value:, upload: nil)
    upload_id = nil
    upload_id = upload.id if upload

    DataAssociation.new(
      parent_id: parent_id,
      parent_class: parent_class,
      key: key.to_s,
      object: { key => value }.to_json,
      upload_id: upload_id
    )
  end

  # Returns associations for the object identified by parent class and id.
  # If key is non-nil, returns the current value for the key, otherwise returns
  # all values ordered by key and last update.
  #
  # @param parent_class [string] the name of the class of the owner object
  # @param parent_id [integer] the record id for the owner object
  # @param key [string] the key value, may be nil
  # @return [ActiveRecord<DataAssociation>] the associations for the object
  def self.associations_for(parent_class:, parent_id:, key: nil)
    if key
      DataAssociation
        .includes(:upload)
        .where(parent_id: parent_id, parent_class: parent_class, key: key.to_s)
        .descending_by_recent_update
    else
      DataAssociation
        .includes(:upload)
        .where(parent_id: parent_id, parent_class: parent_class)
        .descending_by_recent_update
    end
  end

  # Scope method to order data associations by key and then duplicates
  # by descending order on update and ID.
  # So, the first key-value pair, is the most recent update.
  def self.descending_by_recent_update
    order(:key, updated_at: :desc, id: :desc)
  end

  # Filters data associations to keep most recent update for a key.
  # In case of ties, selects largest ID.
  #
  # @param associations [ActiveRecord<DataAssociation>] the data associations
  # @return associations filtered to include the most recently updated values
  def self.select_most_recent(associations)
    associations
      .descending_by_recent_update
      .group_by(&:key)
      .map { |_, group| group.first }
  end
end
