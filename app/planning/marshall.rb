module Marshall

  def self.user= u
    @@user = u
  end

  def self.plan x

    raise "No user defined in Marhsall method" unless @@user

    p = Plan.new(
      name: x[:name],
      cost_limit: x[:cost_limit],
      status: x[:status],
      user_id: @@user.id
    )

    p.save

    self.operations p, x[:operations]   
    self.wires p, x[:wires] if x[:wires] && p.errors.empty?

    p

  end

  def self.operations p, ops

    ids = []

    ops.each do |op|
      begin
        if op[:id]
          operation = self.operation_update op
        else
          operation = self.operation op
          operation.associate_plan p
          operation.save
        end
        ids << operation.id
        @@id_map[operation.id] = op[:rid]
       rescue Exception => e
        raise "Marshalling error: #{e.to_s}: #{e.backtrace[0].to_s}"
      end
    end

    ids

  end

  def self.operation x

    ot = OperationType.find(x[:operation_type_id])
    op = ot.operations.create status: "planning", user_id: @@user.id, x: x[:x], y: x[:y]

    x[:field_values].each do |fv|
      self.field_value op, fv, x[:routing]
    end

    return op

  end

  def self.operation_update op

    operation = Operation.find op[:id]

    operation.x = op[:x]
    operation.y = op[:y]
    operation.save

    op[:field_values].each do |fv|
      self.field_value operation, fv, op[:routing]
    end    

    # for each field value in operation, delete it if it is not in x
    operation.field_values.each do |fv|
      unless op[:field_values].collect { |v| fv[:id] }.member? fv.id
        fv.destroy
      end
    end

    return operation

  end

  def self.wires p, wires

    ids = []

    wires.each do |x_wire|
      if !x_wire[:id]
        wire = Wire.new({
          from_id: @@id_map[x_wire[:from][:rid]], 
          to_id: @@id_map[x_wire[:to][:rid]],
          active: true
        })
        wire.save
        ids << wire.id
      else
        ids << x_wire[:id]
      end
    end

    ids

  end

  def self.field_value op, fv, routing


    if routing[fv[:routing]]
      sid = self.sid(routing[fv[:routing]])
    elsif fv[:child_sample_id]
      sid = fv[:child_sample_id]
    end

    ft = op.operation_type.type(fv[:name],fv[:role])

    item = ( fv[:role] == 'input' && fv[:selected_item] ) ? fv[:selected_item] : nil

    if fv[:role] == 'input' && fv[:selected_item]

      if fv[:selected_item][:collection]
        item = fv[:selected_item][:collection]
        row = fv[:selected_row]
        column = fv[:selected_column]
      else
        item = fv[:selected_item]
        row = nil
        column = nil  
      end
    else
      item = nil
    end

    atts =  { name: fv[:name],
        role: fv[:role], 
        field_type_id: ft.id,
        child_sample_id: sid,
        child_item_id: fv[:child_item_id],
        allowable_field_type_id: fv[:allowable_field_type_id],
        row: item ? row : nil,
        column: item ? column : nil,
        row: item ? row : nil,
        value: fv[:value]
      }

    if fv[:id]

      field_value = FieldValue.find(fv[:id])
      field_value.update_attributes(atts)

    else

      field_value = op.field_values.create(atts)

    end

    self.map_id fv[:rid], field_value.id

    unless field_value.errors.empty?
      raise "Marshalling error: " + op.operation_type.name + " operation: " + field_value.errors.full_messages.join(", ")
    end

  end    

  def self.plan_update x

    p = Plan.find(x[:id])
    p.name = x[:name] ? x[:name] : "New Plan"
    p.cost_limit = x[:cost_limit]
    p.status = x[:status]
    p.user_id = @@user.id
    p.save

    # for each x operation, if the operation exists, update it, else create it
    op_ids = self.operations p, x[:operations]
   
    puts "op_ids = #{op_ids} while plan ops = #{p.operations.collect { |o| o.id }}"

    # for each plan operation, if it is not in x, then delete it
    p.operations.each do |pop|
      unless op_ids.member?(pop.id)
        puts "Destroying op #{pop.id}"
        pop.destroy
        puts pop.errors.full_messages.join(", ")
      end
    end

    # for each x wire, if the wire doesn't exist, create it
    if x[:wires] 
      wire_ids = self.wires p, x[:wires]
    else 
      wire_ids = []
    end

    # for each plan wire, if the wire is not in x, then delete it
    p.wires.each do |pwire|
      unless !x[:wires] || wire_ids.member?(pwire.id)
        pwire.destroy
      end
    end

    p.reload

    p

  end

  def self.sid str
    str ? str.split(':')[0] : nil
  end  

  def self.map_id rid, id
    @@id_map ||= []
    @@id_map[rid] = id
  end  

end