class WorkflowProcess < ActiveRecord::Base

  attr_accessible :state, :workflow_id

  has_many :jobs
  belongs_to :workflow

  # Process Creation and setup

  def self.create workflow, threads, debug=false
    wp = WorkflowProcess.new
    wp.workflow_id = workflow.id
    wp.save
    wp.setup workflow, threads, debug
    wp
  end

  def setup workflow, threads, debug

    Rails.logger.info "WORKFLOW PROCESS SETUP: debug.class = #{debug.class}"

    @cached_state = workflow.export
    @num_threads = threads.length

    threads.each do |t|
    
      t.process_id = self.id
      t.save
      t.reload

      spec = t.spec # parses the json

      Rails.logger.info "WORKFLOW PROCESS SETUP: Thread #{t.id} with spec #{t.spec}"

      spec.each do |assignment|
        Rails.logger.info "WORKFLOW PROCESS SETUP:   Setting up #{assignment}"
        self.instantiate assignment
      end   

    end

    # self.state = @state_hash.to_json

    # instantiate remaining i/o to default
    operation_containers.each do |oc|
      (parts oc).each do |p|
        if p[:shared]
          n = ((@num_threads.to_f) / p[:limit]).ceil
        else
          n = @num_threads
        end
        p[:instantiation] ||= (1..n).collect { |i| default_ispec p  }
      end
    end

    state_hash[:debug] = debug
    puts "WP: set state_hash[:debug] to #{debug} to get #{state_hash[:debug]} with class #{state_hash[:debug].class}"
    self.save_state

  end

  def debug?
    self.state_hash[:debug]
  end

  def default_ispec p

    if p[:alternatives] && p[:alternatives].length > 0
      p[:alternatives][0]
    else 
      {}
    end

  end

  def instantiate a 

    self.operation_containers.each do |oc|
      (parts oc).each do |part|
        if part[:name] == a[:name]
          if part[:shared] && part[:instantiation] && part[:instantiation].length >= ((@num_threads.to_f) / part[:limit]).ceil
            return
          end
          part[:instantiation] ||= []
          if part[:alternatives] && part[:alternatives].length > 0
            base = part[:alternatives].first
          else
            base = {}
          end
          part[:instantiation] << base.merge(a.except :name)
        end
      end
    end
  end

  # Launching and updating

  def input_wired? oid, name
    io.each do |connection|
      return true if connection[:to] == [ oid, name ]
    end
    false
  end

  def initializer? oc # returns true if the operation container's op should be run
                      # initially, when the process starts
    ((inputs oc).collect { |i| ! input_wired? oc[:id], i[:name] }).inject(true,:&)
  end

  def launch

    # find initial protocols to launch.
    initial_ocs = self.operation_containers.select { |oc| initializer? oc }

    # launch jobs
    initial_ocs.each do |oc|

      op = Operation.find(oc[:id])
      jid = op.enqueue oc[:operation], oc[:timing], self.id
      oc[:jid] = jid 
      self.save_state
      Rails.logger.info "WORKFLOW PROCESS(launch): Submitted job #{jid} and saved the jid in the oc"

      if state_hash[:debug]
        Rails.logger.info "WORKFLOW PROCESS(launch): starting job #{jid}"
        result = Krill::Client.new.start jid, true
        Rails.logger.info "WORKFLOW PROCESS(launch): result of #{jid}: #{result}"
        j = Job.find(jid)
        Rails.logger.info "WORKFLOW PROCESS(launch): job #{j.id} is #{j.status}"
        record_result_of j
        step
      end      

    end   

  end

  def save_state
    self.state = self.state_hash.to_json
    save!
    unless self.errors.empty?
      raise "Could not save state."
    end
  end

  def completed?
    operation_containers.conjoin { |oc| oc[:jid] && Job.find(oc[:jid]).done? }
  end

  def record_result_of job

    rv = job.return_value
    oc = operation_container_for job

    unless rv[:inputs] && rv[:outputs] && rv[:data]
      raise "Job #{job.id} (#{job.path}) did not return a value whose type is useable in a workflow: #{rv}"
    end

    rv[:inputs].each do |job_input|
      oc_input = (inputs oc).find { |o| job_input[:name] == o[:name] }
      oc_input[:instantiation] = job_input[:instantiation]
    end

    rv[:outputs].each do |job_output|
      oc_output = (outputs oc).find { |o| job_output[:name] == o[:name] }
      oc_output[:instantiation] = job_output[:instantiation]
    end

    rv[:data].each do |job_data|
      oc_data = (data oc).find { |o| job_data[:name] == o[:name] }
      oc_data[:instantiation] = job_data[:instantiation]
    end

    self.save_state   

  end

  def step

    operation_containers.each do |oc|

      unless operation_completed? oc

        links = incoming oc

        if links.length > 0 && links.conjoin { |link| operation_completed?(operation_container link[:from][0]) }

          (inputs oc).each do |input|

            # update instantiations
            links.each do |link|
              if input[:name] == link[:to][1]
                source = operation_container link[:from][0]
                input[:instantiation] = output(link[:from][1], source)[:instantiation]
                # TODO: This should be a unificiation, not an assignment.
              end
            end       

          end

          # launch job
          op = Operation.find(oc[:id])
          jid = op.enqueue oc[:operation], oc[:timing], self.id
          oc[:jid] = jid       
          save_state

          if state_hash[:debug]
            puts "WP: starting job #{jid}"
            result = Krill::Client.new.start jid, true
            j = Job.find(jid)
            puts "WP: job #{j.id} is #{j.status}"
            record_result_of j
            step
          end                   

        end

      end

    end    

    true

  end

  # Getters, setters

  def output name, oc

    oc[:operation][:outputs].find { |i| i[:name] == name } 

  end

  def incoming oc
    io.select { |link| 
      link[:to][0] == oc[:id]
    }
  end  

  def io
    self.state_hash[:specification][:io]
  end

  def state_hash    
    @cached_state ||= JSON.parse self.state, symbolize_names: true
    @cached_state
  end

  def clear_cache
    @cached_state = nil
  end

  def operation_containers
    self.state_hash[:specification][:operations]
  end

  def operation_container id
    oc = (self.state_hash[:specification][:operations].select { |o| o[:id] == id }).first
    raise "could not find operation container #{id}" unless oc
    oc
  end

  def operation_container_for job
    oc = self.state_hash[:specification][:operations].find { |o| o[:jid] == job.id }
    raise "could not find operation container for #{job.id}" unless oc
    oc
  end

  def operation_completed? oc
    oc[:jid] != nil && Job.find(oc[:jid]).status == "COMPLETED"
  end

  def inputs oc
    oc[:operation][:inputs]
  end

  def outputs oc
    oc[:operation][:outputs]
  end  

  def params oc
    oc[:operation][:parameters]
  end  

  def data oc
    oc[:operation][:data]
  end

  def parts oc
    inputs(oc) + outputs(oc) + params(oc) + data(oc)
  end

  def all_parts
    p = []
    self.operation_containers.each do |oc|
      p += parts oc
    end
    p
  end

end
