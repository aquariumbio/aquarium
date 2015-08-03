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
  has_many :uploads
  belongs_to :group
  has_many :post_associations

  def self.params_to_time p

    DateTime.civil_from_format(:local,
      p["dt(1i)"].to_i, 
      p["dt(2i)"].to_i,
      p["dt(3i)"].to_i,
      p["dt(4i)"].to_i,
      p["dt(5i)"].to_i).to_time

  end

  def done?
    return (self.pc == -2)
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
    bt = self.backtrace
    bt.concat steps
    self.state = bt.to_json
    self.save
  end

  def append_step step
    bt = self.backtrace
    bt.push step
    self.state = bt.to_json
    self.save 
  end

  def submitter
    u = User.find_by_id(self.submitted_by)
    if u
        u.login
    else
        "?"
    end
  end

  def doer
    u = User.find_by_id(self.user_id.to_i)
    if u
        u.login
    else
        "?"
    end
  end

  def arguments
    begin
      if /\.rb$/ =~ self.path
        (JSON.parse(self.state)).first["arguments"]
      else
        (JSON.parse(self.state))['stack'].first.reject { |k,v| k == 'user_id' }
      end
    rescue Exception => e
      { error: "unable to parse arguments" }
    end
  end

  def start_link el, opts={}

    options = { confirm: false }.merge opts

    confirm = options[:confirm] ? "class='confirm'" : ""

    if /\.rb$/ =~ self.path

      if self.pc == Job.NOT_STARTED 
        "<a #{confirm} target=_top href='/krill/start?job=#{self.id}'>#{el}</a>".html_safe
      else 
        "<a #{confirm} target=_top href='/krill/ui?job=#{self.id}'>#{el}</a>".html_safe
      end 

    else 

      if self.pc == Job.NOT_STARTED 
        "<a #{confirm} target=_top href='/interpreter/advance?job=#{self.id}'>#{el}</a>".html_safe 
      elsif self.pc != Job.COMPLETED 
        "<a #{confirm} target=_top href='/interpreter/current?job=#{self.id}'>#{el}</a>".html_safe 
      end 

    end 

  end

  def remove_types p

    case p
      when String, Fixnum, Float, TrueClass, FalseClass
        p
      when Hash
        h = {}
        p.keys.each do |key|
          h[key.to_s.split(' ')[0].to_sym] = remove_types(p[key])
        end
        h
      when Array
        p.collect do |a|
          remove_types a
        end
    end

  end

  def set_arguments a

    if /\.rb$/ =~ self.path
      self.state = [{operation: "initialize", arguments: (remove_types a), time: Time.now}].to_json
    else
      raise "Could not set arguments of non-krill protocol"
    end

  end

  def return_value

    if /\.rb$/ =~ self.path

      begin
        @rval = JSON.parse(self.state, symbolize_names: true).last[:rval] || {}
      rescue
        @rval = { error: "Could not find return value." }
      end      

    else

      entries = self.logs.reject { |l| l.entry_type != 'return' }
      if entries.length == 0
        return nil
      else
        JSON.parse(entries.first.data,:symbolize_names => true)
      end

    end

  end

  def cancel user
    if self.pc != Job.COMPLETED
      self.pc = Job.COMPLETED
      self.user_id = user.id
      if /\.rb$/ =~ self.path
        Krill::Client.new.abort self.id
        self.abort_krill 
      end
      self.save
    end
  end

  def krill?
    if /\.rb$/ =~ self.path
      return true
    else
      return false
    end
  end

  def plankton?
    if /\.pl$/ =~ self.path
      return true
    else
      return false
    end
  end  

  def error?

    if krill? 
      begin
        return self.done? && self.backtrace.last[:operation] != "complete"
      rescue
        return true
      end
  elsif plankton?
      entries = self.logs.reject { |l| l.entry_type != 'CANCEL' && l.entry_type != 'ERROR' && l.entry_type != 'ABORT' }
      return entries.length > 0
    else
      false
    end

  end

  def abort_krill

    self.pc = Job.COMPLETED

    state = JSON.parse self.state, symbolize_names: true
    if state.length % 2 == 1 # backtrace ends with a 'next'
      self.append_step operation: "display", content: [ 
        { title: "Interrupted" },
        { note: "This step was being prepared by the protocol when the 'abort' signal was received."} ]
    end

    # add next and final
    self.append_step operation: "next", time: Time.now, inputs: {}
    self.append_step operation: "aborted", rval: {}

  end

  def num_posts
    self.post_associations.count
  end

  def export
    a = attributes
    begin
      a["backtrace"] = JSON.parse a["state"], symbolize_names: true
    rescue
      a["backtrace"] = { error: "Could not parse backtrace." }
    end
    a.delete "state"
    a
  end

end
