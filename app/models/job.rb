class Job < ActiveRecord::Base

  attr_accessible :arguments, :sha, :state, :user_id, :pc

  def self.NOT_STARTED
    -1
  end

  def self.COMPLETED
    -2
  end

  has_many :logs
  has_many :touches
  belongs_to :user

end
