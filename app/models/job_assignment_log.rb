class JobAssignmentLog < ActiveRecord::Base

  attr_accessible :job_id, :assigned_by, :assigned_to

  belongs_to :job
  belongs_to :assigned_by_user, class_name: "User", foreign_key: "assigned_by"
  belongs_to :assigned_to_user, class_name: "User", foreign_key: "assigned_to"

  ### VALIDATIONS

  # VALIDATE FOREIGN KEYS ON SAVE
  def save
    err = nil
    err = 1 if !job_id_exists
    err = 1 if !assigned_by_exists
    err = 1 if !assigned_to_exists

    err ? nil : super
  end

  # VALIDATE FOREIGN KEYS ON SAVE!
  def save!
    err = nil
    err = 1 if !job_id_exists
    err = 1 if !assigned_by_exists
    err = 1 if !assigned_to_exists

    err ? nil : super
  end

  private

  def job_id_exists
    if Job.exists?(self.job_id)
      return true
    else
      self.errors[:job_id] << "Job does not exist"
      return false
    end
  end

  def assigned_by_exists
    if User.exists?(self.assigned_by)
      return true
    else
      self.errors[:assigned_by] << "Assigned_By user does not exist"
      return false
    end
  end

  def assigned_to_exists
    if User.exists?(self.assigned_to)
      return true
    else
      self.errors[:assigned_to] << "Assigned_To user does not exist"
      return false
    end
  end

end
