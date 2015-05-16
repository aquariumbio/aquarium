class Workflow < ActiveRecord::Base

  attr_accessible :name, :specification

  def parse_spec
    JSON.parse specification, symbolize_names: true
  end

  def expand
    s = parse_spec
    s[:operations] = s[:operations].collect { |o|
      op = Operation.find(o)
      op.parse_spec.merge id: o, name: op.name, protocol: op.protocol_path
    }
    { id: id, name: name, specification: s }
  end

end
