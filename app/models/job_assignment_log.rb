class JobAssignmentLog < ActiveRecord::Base

  attr_accessible :job_id, :assigned_by, :assigned_to

  belongs_to :job
  belongs_to :assigned_by_user, class_name: "User", foreign_key: "assigned_by"
  belongs_to :assigned_to_user, class_name: "User", foreign_key: "assigned_to"

  validate :job_id_exists
  validate :assigned_by_exists
  validate :assigned_to_null_or_exists

  private

  def job_id_exists
    unless Job.exists?(self.job_id)
      self.errors[:job_id] << "invalid job"
      return false
    end

    true
  end

  def assigned_by_exists
    unless User.exists?(self.assigned_by)
      self.errors[:by_id] << "invalid user"
      return false
    end

    true
  end

  def assigned_to_null_or_exists
    unless !self.assigned_to or ( self.assigned_to and User.exists?(self.assigned_to) )
      self.errors[:to_id] << "invalid user"
      return false
    end

    true
  end

end
