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
  has_many :takes

  def self.params_to_time p

    DateTime.civil_from_format(:local,
      p["dt(1i)"].to_i, 
      p["dt(2i)"].to_i,
      p["dt(3i)"].to_i,
      p["dt(4i)"].to_i,
      p["dt(5i)"].to_i).to_time

  end

  def status
    if self.pc >= 0
      status = 'ACTIVE'
    elsif self.pc == Job.NOT_STARTED
      status = 'PENDING'
    else
      entries = (self.logs.reject { |log| 
        log.entry_type != 'ERROR' && log.entry_type != 'ABORT' && log.entry_type != 'CANCEL' 
      }).collect { |log| log.entry_type }
      if entries.length > 0
        status = entries[0] == 'ERROR' ? entries[0] : entries[0] + "ED"
      else
        status = "COMPLETED"
      end
    end
    return status
  end

  def backtrace
    JSON.parse self.state, symbolize_names: true
  end

  def append_steps steps
    bt = backtrace
    bt.concat steps
    self.state = bt
    self.save
  end

  def append_step step

    bt = backtrace
    bt.push step
    self.state = bt.to_json
    self.save 

  end

end
