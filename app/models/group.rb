# typed: false
# frozen_string_literal: true

class Group < ApplicationRecord

  attr_accessible :description, :name
  has_many :memberships, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def add(user)
    memberships.create!(user_id: user.id)
  end

  def member?(user)
    memberships.where(user_id: user.id).present?
  end

  def self.list_names
    active_logins = User.select_active.collect(&:login).sort
    group_names = non_user_groups.collect(&:name).sort - ['retired']
    { groups: group_names, users: active_logins }
  end

  # Scope to limit groups to non-user groups.
  def self.non_user_groups
    where.not(name: User.logins)
  end

  def self.admin
    get_group(name: 'admin', description: 'Administrative users')
  end

  def self.retired
    get_group(name: 'retired', description: 'Retired Users')
  end

  def self.technicians
    get_group(name: 'technicians', description: 'Users who carryout protocols')
  end

  # [private method]
  # Gets the group with the name.
  # If the named group exists, returns the group.
  # Otherwise, returns the group created with the name and description.
  #
  # Note: Does not change the description of an existing group.
  #
  # @param name [String] the name of the group
  # @param description [String] the description for a new group
  # @return [Group] the named group
  def self.get_group(name:, description:)
    group = Group.find_by(name: name)
    group ||= Group.create(name: name, description: description)

    group
  end

  private_class_method :get_group
end
