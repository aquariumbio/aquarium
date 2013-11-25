class Metacol < ActiveRecord::Base

  attr_accessible :path, :sha, :state, :status, :user_id, :message
  has_many :jobs

  def num_pending_jobs
    (self.jobs.select { |j| j.pc == Job.NOT_STARTED || j.pc >= 0 }).length
  end

end
