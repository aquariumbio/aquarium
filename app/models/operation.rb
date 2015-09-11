class Operation < ActiveRecord::Base

  attr_accessible :name, :protocol_path, :specification

  after_initialize :defaults

  def base_path
    "#{Bioturk::Application.config.workflow[:repo]}/auto/#{Rails.env}"
  end

  def path
    "#{base_path}/#{self.id}.rb"
  end

  def default_path
    "#{Bioturk::Application.config.workflow[:repo]}/auto/default.rb"
  end

  def defaults
     unless persisted?
      self.name ||= "Operation"
      self.specification ||= ({ inputs: [], outputs: [], parameters: [], data: [], exceptions: [] }).to_json
      self.protocol_path ||= base_path
    end
  end

  def make_generic_protocol
    Repo.copy default_path, path
  end

  def parse_spec
    JSON.parse specification, symbolize_names: true
  end

  def export
    self.parse_spec.merge(id: self.id, name: self.name, protocol: self.protocol_path)
  end

  def okay_to_drop?
    # TODO: Check that operation is not referenced in any workflow
    true
  end

  def enqueue op, timing, process_id

    job = Job.new
    
    job.workflow_process_id = process_id
    job.path = self.path
    job.sha = Repo.version(job.path)
    job.set_arguments op

    ts = TimeSpec.new timing
    start = ts.parse

    job.desired_start_time = start
    job.latest_start_time = start + 1.hour

    job.group_id = 1
    job.submitted_by = 1
    job.pc = Job.NOT_STARTED
    job.save

    job.id    

  end

end
