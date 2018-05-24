class Metacol < ActiveRecord::Base

  attr_accessible :path, :sha, :state, :status, :user_id, :message

  has_many :jobs
  has_many :touches
  belongs_to :user

  def num_pending_jobs
    (self.jobs.select { |j| j.pc == Job.NOT_STARTED || j.pc >= 0 }).length
  end

  def arguments
    begin
      (JSON.parse self.state, symbolize_names: true)[:stack][0]
    rescue
      { error: "Could not parse arguments" }
    end
  end

end
