# typed: false
# frozen_string_literal: true

class JobAssignmentLog < ActiveRecord::Base

  attr_accessible :job_id, :assigned_by, :assigned_to

  belongs_to :job
  belongs_to :assigned_by_user, class_name: 'User', foreign_key: 'assigned_by'
  belongs_to :assigned_to_user, class_name: 'User', foreign_key: 'assigned_to'

  validate :job_id_exists
  validate :assigned_by_exists
  validate :assigned_to_null_or_exists

  private

  def job_id_exists
    unless Job.exists?(job_id)
      errors[:job_id] << 'invalid job'
      return false
    end

    true
  end

  def assigned_by_exists
    unless User.exists?(assigned_by)
      errors[:by_id] << 'invalid user'
      return false
    end

    true
  end

  def assigned_to_null_or_exists
    unless !assigned_to || (assigned_to && User.exists?(assigned_to))
      errors[:to_id] << 'invalid user'
      return false
    end

    true
  end

end
