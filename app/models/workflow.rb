class Workflow < ActiveRecord::Base

  attr_accessible :name, :specification

  def parse_spec
    JSON.parse specification, symbolize_names: true
  end

  def export
    s = parse_spec
    s[:operations] = s[:operations].collect { |o|
      o.merge operation: Operation.find(o[:id]).export 
    }
    { id: id, name: name, specification: s }
  end

  def add_operation op
    s = parse_spec
    s[:operations].push(op.id)
    self.specification = s.to_json
    self.save
  end

  def new_operation
    op = Operation.new
    op.save
    add_operation op
    op.export
  end

  def drop_operation op
    s = parse_spec
    s[:operations] -= [op.id]
    self.specification = s.to_json
    self.save
    op.destroy if op.okay_to_drop?
  end

  def identify source, dest, output, input
    s = parse_spec
    s[:io].push({from:[source,output],to:[dest,input]})
    self.specification = s.to_json
    self.save
  end

end
