module WorkflowAux

  def wired? oid, name
    @fullspec[:specification][:io].each do |io|
      return true if io[:from] == [ oid, name ] || io[:to] == [ oid, name ]
    end
    false
  end

  def form

    inputs = []
    outputs = []
    parameters = []

    @fullspec = export

    @fullspec[:specification][:operations].each do |h|
      inputs += (h[:operation][:inputs].reject { |i| wired? h[:id], i[:name] }).collect { |i| i.merge oid: h[:id] }
      outputs += (h[:operation][:outputs].reject { |o| wired? h[:id], o[:name] }).collect { |o| o.merge oid: h[:id] }
      parameters += h[:operation][:parameters].collect { |p| p.merge oid: h[:id] }
    end

    {
      inputs: inputs,
      outputs: outputs,
      parameters: parameters
    }

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

end
