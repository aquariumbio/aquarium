module WorkflowAux

  def wired_input? oid, name
    @fullspec[:specification][:io].each do |io|
      return true if io[:to] == [ oid, name ]
    end
    false
  end

  def wired_output? oid, name
    @fullspec[:specification][:io].each do |io|
      return true if io[:from] == [ oid, name ]
    end
    false
  end

  def sample_based? ispec
    ispec[:alternatives].disjoin { |a| a[:sample] }
  end

  def form

    inputs = []
    outputs = []
    parameters = []

    complete_spec[:specification][:operations].each do |h|
      inputs += (h[:operation][:inputs].reject { |i| wired_input?(h[:id], i[:name]) || !sample_based?(i) }).collect { |i| i.merge oid: h[:id] }
      outputs += (h[:operation][:outputs].reject { |o| wired_output?(h[:id], o[:name]) || !sample_based?(o) }).collect { |o| o.merge oid: h[:id] }
      parameters += h[:operation][:parameters].collect { |p| p.merge oid: h[:id] }
    end

    f = { 
      inputs: inputs,
      outputs: outputs,
      parameters: parameters
    }

    Rails.logger.info "WORKFLOW FORM: made form #{f}."

    return f

  end

  def validate spec
    return true # TODO: Actually validate the spec and raise exception if not ok
  end

  def new_thread spec

    validate spec

    t = WorkflowThread.new workflow_id: self.id, specification: spec.to_json
    t.save # should all of this be in a transaction?

    spec.each do |ispec| # TODO: move this somewhere it can be shared
      if ispec[:sample]
        if ispec[:sample].class == String
          sid = ispec[:sample].split(":")[0]
        else
          sid = ispec[:sample]
        end
        wa = WorkflowAssociation.new thread_id: t.id, sample_id: sid
        wa.save
      elsif ispec[:item]
        wa = WorkflowAssociation.new thread_id: t.id, item_id: ispec[:item]
        wa.save
      end
    end

    t

  end

  def make_spec_from_hash h

    s = []

    f = form

    (f[:inputs]+f[:outputs]).each do |i|
      ispec = { name: i[:name], sample: h[i[:name]] }
      unless s.member? ispec
        s << { name: i[:name], sample: h[i[:name]] }
      end
    end

    f[:parameters].each do |p|
      logger.info({p:p,h:h})
      s << { name: p[:name], value: h[p[:name]] }
    end

    s

  end  

end
