# frozen_string_literal: true

# job_assignment_logs table
class JobAssignmentLog < ActiveRecord::Base
  # NOTE: belongs_to will automatically validate if not optional
  # NOTE: the belongs_to names cannot be the same as the table column names
  belongs_to :job, class_name: 'Job', foreign_key: :job_id
  belongs_to :by_id, class_name: 'User', foreign_key: :assigned_by
  belongs_to :to_id, class_name: 'User', foreign_key: :assigned_to, optional: true

  # NOTE: need to validate the assigned_to field (belongs_to :to_id)
  validate :assigned_to_exists_or_null

  private

  def assigned_to_exists_or_null
    unless !assigned_to || (assigned_to && User.exists?(assigned_to))
      errors[:to_id] << 'invalid user'
      return false
    end

    true
  end
end
