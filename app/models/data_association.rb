# frozen_string_literal: true

# @api krill
class DataAssociation < ActiveRecord::Base

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
    return user.is_admin if parent_class == 'Collection' # since collections are managed by admins?
    return true if parent_class == 'Operation' # since operations don't yet have owners (actually they do now, so this should be fixed)
    return true if parent_class == 'Plan' # plans don't have owners yet either
    return true if parent_class == 'OperationType' # operation types don't have owners yet either
  end

end
