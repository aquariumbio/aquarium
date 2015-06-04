class Operation < ActiveRecord::Base

  attr_accessible :name, :protocol_path, :specification

  after_initialize :defaults

  def defaults
     unless persisted?
      self.name ||= "Operation"
      self.specification ||= ({ inputs: [], outputs: [], parameters: [], data: [], exceptions: [] }).to_json
      self.protocol_path ||= ""
    end
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

  # Methods for adding new parts to an operation

  def new_part_name 
    s = self.parse_spec
    names = (s[:inputs]+s[:outputs]+s[:exceptions]+s[:data]+s[:parameters]).collect { |p| p[:name] }
    name = "O"+SecureRandom.hex(2)
    while names.member? name
      name = "O"+SecureRandom.hex(2)
    end
    name
  end

  def new_part type     # e.g. op.new_part :parameters
    raise "Illegal type: :#{type}." unless [:inputs,:outputs,:data,:parameters].member? type
    s = self.parse_spec
    name = self.new_part_name
    s[type].push({name: name})
    self.specification = s.to_json
    self.save
    name
  end

  def new_exception
    s = self.parse_spec
    s[:exceptions].push({name: self.new_part_name, outputs: [], data: []})
    self.specification = s.to_json
    self.save
  end

  def new_exception_part_name e
    names = (e[:outputs]+e[:data]).collect { |p| p[:name] }
    name = "E"+SecureRandom.hex(2)
    while names.member? name
      name = "E"+SecureRandom.hex(2)
    end
    name
  end

  def new_exception_part type, ename
    raise "Illegal type: :#{type}." unless [:outputs,:data].member? type    
    s = self.parse_spec
    es = s[:exceptions].select { |e| e[:name] == ename }
    others = s[:exceptions].reject { |e| e[:name] == ename }
    raise "Exception named '#{ename}' not found, or inconsistent exception." unless es.length == 1
    e = es[0]
    e[type].push({name: self.new_exception_part_name(e)})
    s[:exceptions] = [e] + others
    self.specification = s.to_json
    self.save
  end

  def drop_part type, name
    raise "Illegal type: :#{type}." unless [:inputs,:outputs,:data,:parameters].member? type
    s = self.parse_spec
    s[type] = s[type].reject { |p| p[:name] == name }
    self.specification = s.to_json
    self.save
  end

  def rename name
    self.name = name
    self.save
  end

  def rename_part type, old_name, new_name
    raise "Illegal type: :#{type}." unless [:inputs,:outputs,:data,:parameters].member? type
    s = self.parse_spec
    matching_parts = s[type].select { |p| p[:name] == old_name }
    raise "#{new_name} not found." unless matching_parts.length == 1
    part = matching_parts[0]
    other_parts = s[type].reject { |p| p[:name] == old_name }
    part[:name] = new_name
    s[type] = [part] + other_parts
    self.specification = s.to_json
    self.save    
  end

end
