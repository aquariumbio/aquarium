# frozen_string_literal: true

class Group < ActiveRecord::Base

  attr_accessible :description, :name
  has_many :memberships, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def member?(uid)
    memberships.where(user_id: uid).present?
  end

  def self.list_names
    users = User.logins
    active_logins = User.select_active.collect(&:login).sort
    group_names = non_user_groups.collect(&:name).sort - ['retired']
    { groups: group_names, users: active_logins }
  end

  # Scope to limit groups to non-user groups.
  def self.non_user_groups
    where.not(name: User.logins)
  end

  def self.admin
    admin = Group.find_by(name: 'admin')
    unless admin
      admin = Group.create(name: 'admin', description: 'Administrative users')
    end

    admin
  end

  def self.retired
    retired = Group.find_by(name: 'retired')
    unless retired
      retired = Group.create(name: 'retired', description: 'Retired Users')
    end

    retired
  end

  def self.technicians
    technicians = Group.find_by(name: 'technicians')
    unless technicians
      technicians = Group.create(name: 'technicians', description: 'Users who carryout protocols')
    end

    technicians
  end
end
