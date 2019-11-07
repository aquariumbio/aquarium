# frozen_string_literal: true

# @api krill
class Parameter < ApplicationRecord

  attr_accessible :key, :value, :description, :user_id

  belongs_to :user

  def self.make(key, value)
    p = Parameter.new key: key, value: value, description: 'Edit me'
    p.save
    p
  end

  def self.get_float(key)
    p = Parameter.find_by(key: key)
    p ||= Parameter.make(key, '0.0')

    p.value.to_f
  end

  def self.get_string(key)
    p = Parameter.find_by(key: key)
    p ||= Parameter.make(key, '')

    p.value
  end

  def self.get(key)
    get_string key
  end

end
