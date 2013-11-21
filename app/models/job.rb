class Job < ActiveRecord::Base

  attr_accessible :arguments, :sha, :state, :user_id, :pc, :submitted_by, :group_id, :desired_start_time, :latest_start_time, :metacol_id

  def self.NOT_STARTED
    -1
  end

  def self.COMPLETED
    -2
  end

  has_many :logs
  has_many :touches
  belongs_to :user
  belongs_to :metacol

  def self.params_to_time p

    DateTime.civil_from_format(:local,
      p["dt(1i)"].to_i, 
      p["dt(2i)"].to_i,
      p["dt(3i)"].to_i,
      p["dt(4i)"].to_i,
      p["dt(5i)"].to_i).to_time

  end

end
