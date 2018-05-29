# frozen_string_literal: true

class Metacol < ActiveRecord::Base

  attr_accessible :path, :sha, :state, :status, :user_id, :message

  has_many :jobs
  has_many :touches
  belongs_to :user

  def num_pending_jobs
    (jobs.select { |j| j.pc == Job.NOT_STARTED || j.pc >= 0 }).length
  end

  def arguments

    (JSON.parse state, symbolize_names: true)[:stack][0]
  rescue StandardError
    { error: 'Could not parse arguments' }

  end

end
