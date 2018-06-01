

class Job < ActiveRecord::Base

  include JobOperations

  attr_accessible :arguments, :state, :user_id, :pc, :submitted_by, :group_id,
                  :desired_start_time, :latest_start_time, :metacol_id, :successor

  has_many :job_associations
  # has_many :operations, through: :jobs_associations # not working for some reason
  def operations
    job_associations.collect(&:operation)
  end

  def self.NOT_STARTED
    -1
  end

  def self.COMPLETED
    -2
  end

  has_many :logs
  belongs_to :user
  belongs_to :metacol
  has_many :uploads
  belongs_to :group
  has_many :post_associations
  belongs_to :workflow_process

  belongs_to :successor, class_name: 'Job'
  has_many :predecessors, class_name: 'Job', foreign_key: :successor_id

  def self.params_to_time(p)

    DateTime.civil_from_format(:local,
                               p['dt(1i)'].to_i,
                               p['dt(2i)'].to_i,
                               p['dt(3i)'].to_i,
                               p['dt(4i)'].to_i,
                               p['dt(5i)'].to_i).to_time

  end

  def done?
    pc == Job.COMPLETED
  end

  def not_started?
    pc == Job.NOT_STARTED
  end

  def pending?
    not_started?
  end

  def active?
    pc >= 0
  end

  def status
    if pc >= 0
      status = 'ACTIVE'
    elsif pc == Job.NOT_STARTED
      status = 'PENDING'
    else
      entries = (logs.reject do |log|
        log.entry_type != 'ERROR' && log.entry_type != 'ABORT' && log.entry_type != 'CANCEL'
      end).collect(&:entry_type)
      status = if !entries.empty?
                 entries[0] == 'ERROR' ? entries[0] : entries[0] + 'ED'
               else
                 'COMPLETED'
               end
    end
    status
  end

  def backtrace
    JSON.parse state, symbolize_names: true
  end

  def append_steps(steps)
    bt = backtrace
    bt.concat steps
    self.state = Oj.dump(bt, mode: :compat)
    save
  end

  def append_step(step)
    bt = backtrace
    bt.push step
    self.state = Oj.dump(bt, mode: :compat)
    save
  end

  def submitter
    u = User.find_by_id(submitted_by)
    if u
      u.login
    else
      '?'
    end
  end

  def doer
    u = User.find_by_id(user_id.to_i)
    if u
      u.login
    else
      '?'
    end
  end

  def arguments

    if /\.rb$/ =~ path
      JSON.parse(state).first['arguments']
    else
      JSON.parse(state)['stack'].first.reject { |k, _v| k == 'user_id' }
    end
  rescue Exception => e
    { error: 'unable to parse arguments' }

  end

  def start_link(el, opts = {})

    options = { confirm: false }.merge opts

    confirm = options[:confirm] ? "class='confirm'" : ''

    if /\.rb$/ =~ path

      if pc == Job.NOT_STARTED
        "<a #{confirm} target=_top href='/krill/start?job=#{id}'>#{el}</a>".html_safe
      else
        "<a #{confirm} target=_top href='/krill/ui?job=#{id}'>#{el}</a>".html_safe
      end

    else

      if pc == Job.NOT_STARTED
        "<a #{confirm} target=_top href='/interpreter/advance?job=#{id}'>#{el}</a>".html_safe
      elsif pc != Job.COMPLETED
        "<a #{confirm} target=_top href='/interpreter/current?job=#{id}'>#{el}</a>".html_safe
      end

    end

  end

  def remove_types(p)

    case p
    when String, Integer, Float, TrueClass, FalseClass
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

  def set_arguments(a)

    if /\.rb$/ =~ path
      self.state = [{ operation: 'initialize', arguments: (remove_types a), time: Time.now }].to_json
    else
      raise 'Could not set arguments of non-krill protocol'
    end

  end

  def return_value

    if /\.rb$/ =~ path

      begin
        @rval = JSON.parse(state, symbolize_names: true).last[:rval] || {}
      rescue StandardError
        @rval = { error: 'Could not find return value.' }
      end

    else

      entries = logs.select { |l| l.entry_type == 'return' }
      if entries.empty?
        return nil
      else
        JSON.parse(entries.first.data, symbolize_names: true)
      end

    end

  end

  def cancel(user)
    if pc != Job.COMPLETED
      self.pc = Job.COMPLETED
      self.user_id = user.id
      if /\.rb$/ =~ path
        Krill::Client.new.abort id
        abort_krill
      end
      save
    end
  end

  def krill?
    if /\.rb$/ =~ path
      true
    else
      false
    end
  end

  def plankton?
    if /\.pl$/ =~ path
      true
    else
      false
    end
  end

  def error?

    if krill?
      begin
        return done? && backtrace.last[:operation] != 'complete'
      rescue StandardError
        return true
      end
    elsif plankton?
      entries = logs.reject { |l| l.entry_type != 'CANCEL' && l.entry_type != 'ERROR' && l.entry_type != 'ABORT' }
      !entries.empty?
    else
      false
    end

  end

  def error_message
    backtrace[-3][:message]
  end

  def error_backtrace
    backtrace[-3][:backtrace]
  end

  def abort_krill

    self.pc = Job.COMPLETED

    state = JSON.parse self.state, symbolize_names: true
    if state.length.odd? # backtrace ends with a 'next'
      append_step operation: 'display', content: [
        { title: 'Interrupted' },
        { note: "This step was being prepared by the protocol when the 'abort' signal was received." }
      ]
    end

    # add next and final
    append_step operation: 'next', time: Time.now, inputs: {}
    append_step operation: 'aborted', rval: {}

  end

  def num_posts
    post_associations.count
  end

  def export
    a = attributes
    begin
      a['backtrace'] = JSON.parse a['state'], symbolize_names: true
    rescue StandardError
      a['backtrace'] = { error: 'Could not parse backtrace.' }
    end
    a.delete 'state'
    a
  end

  def step_workflow

    if workflow_process
      begin
        wp = WorkflowProcess.find(workflow_process.id)
        wp.record_result_of self
        wp.step
      rescue Exception => e
        Rails.logger.info 'Error trying to step workflow process ' + e.to_s
      end
    end

  end

  def name
    path.split('/').last.split('.').first
  end

  def active_predecessors
    predecessors.reject(&:done?)
  end

  def reset

    puts Krill::Client.new.abort id
    self.state = [{ 'operation' => 'initialize', 'arguments' => {}, 'time' => '2017-06-02T11:40:20-07:00' }].to_json
    self.pc = 0
    save
    puts Krill::Client.new.start id
    reload

  end

end
