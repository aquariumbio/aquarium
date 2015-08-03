class WorkflowProcess < ActiveRecord::Base

  attr_accessible :state, :workflow_id

  # Process Creation and setup

  def self.create workflow, threads
    wp = WorkflowProcess.new
    wp.setup workflow, threads
    wp
  end

  def setup workflow, threads

    @cached_state = workflow.export
    @num_threads = threads.length

    threads.each do |t|
    
      spec = t.spec # parses the json

      spec.each do |assignment|
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

    self.state = self.state_hash.to_json
    self.save

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
          if part[:shared] && part[:instantiation] && part[:instantiation].length >= ((@num_threads.to_f) / p[:limit]).ceil
            return
          end
          part[:instantiation] ||= []
          part[:instantiation] << (a.except :name)
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
      jid = op.enqueue oc[:operation], oc[:timing]
      oc[:jid] = jid 
    end

    self.save

  end

  def update

  end

  # Getters, setters

  def io
    self.state_hash[:specification][:io]
  end

  def state_hash    
    @cached_state ||= JSON.parse self.state, symbolize_keys: true
    @cached_state
  end

  def operation_containers
    self.state_hash[:specification][:operations]
  end

  def operation_container id
    oc = (self.state_hash[:specification][:operations].select { |o| o[:id] == id }).first
    raise "could not find operation container #{id}" unless oc
    oc
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
