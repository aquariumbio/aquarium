module Marshall

  def self.user=(u)
    @@user = u
  end

  def self.plan(x)

    raise 'No user defined in Marhsall method' unless @@user

    p = Plan.new(
      name: x[:name],
      cost_limit: x[:cost_limit],
      status: x[:status],
      user_id: @@user.id
    )

    p.save

    operations p, x[:operations]
    wires p, x[:wires] if x[:wires] && p.errors.empty?

    p.layout = mod(x[:layout]).to_json
    p.save

    p

  end

  def self.operations(p, ops)

    ids = []

    if ops
      ops.each do |op|
        begin
          if op[:id]
            operation = operation_update op
          else
            operation = self.operation op
            operation.associate_plan p
            operation.save
          end
          ids << operation.id
          map_id op[:rid], operation.id
        rescue Exception => e
          raise "Marshalling error: #{e}: #{e.backtrace[0]}"
        end
      end
    end

    ids

  end

  def self.operation(x)

    ot = OperationType.find(x[:operation_type_id])
    op = ot.operations.create status: 'planning', user_id: @@user.id, x: x[:x], y: x[:y], parent_id: x[:parent_id]

    if x[:field_values]
      x[:field_values].each do |fv|
        field_value op, fv, x[:routing]
      end
    end

    op

  end

  def self.operation_update(op)

    operation = Operation.find op[:id]

    operation.x = op[:x]
    operation.y = op[:y]
    operation.parent_id = op[:parent_id]
    operation.save
    current_fvs = []

    if op[:field_values]
      op[:field_values].each do |raw_fv|
        current_fv = field_value operation, raw_fv, op[:routing]
        current_fvs << current_fv
      end
    end

    # for each field value in operation, delete it if it is not a raw_fv
    operation.field_values.each do |fv|
      fv.destroy unless current_fvs.collect { |current_fv| current_fv[:id] }.member? fv.id
    end

    operation

  end

  def self.wires(_p, wires)

    ids = []

    wires.each do |x_wire|
      if !x_wire[:id]
        wire = Wire.new(
          from_id: @@id_map[x_wire[:from][:rid]],
          to_id: @@id_map[x_wire[:to][:rid]],
          active: true
        )
        wire.save
        ids << wire.id
      else
        ids << x_wire[:id]
      end
    end

    ids

  end

  def self.field_value(op, fv, routing)

    if !fv[:array] && routing[fv[:routing]]
      sid = self.sid(routing[fv[:routing]])
    elsif fv[:child_sample_id]
      sid = fv[:child_sample_id]
    end

    ft = op.operation_type.type(fv[:name], fv[:role])

    aft = AllowableFieldType.find_by(id: fv[:allowable_field_type_id])
    sample = Sample.find_by(id: sid)

    sid = nil if aft && (!sample || aft.sample_type_id != sample.sample_type_id)

    atts = { name: fv[:name],
             role: fv[:role],
             field_type_id: ft.id,
             child_sample_id: sid,
             child_item_id: fv[:child_item_id],
             allowable_field_type_id: fv[:allowable_field_type_id],
             row: fv[:row],
             column: fv[:column],
             value: fv[:value] }

    if fv[:id]

      field_value = FieldValue.find(fv[:id])
      field_value.update(atts)

    else

      field_value = op.field_values.create(atts)

    end

    map_id fv[:rid], field_value.id

    unless field_value.errors.empty?
      raise 'Marshalling error: ' +
            op.operation_type.name + ' operation: ' +
            field_value.errors.full_messages.join(', ')
    end

    field_value

  end

  def self.plan_update(x)

    p = Plan.find(x[:id])
    p.name = x[:name] ? x[:name] : 'New Plan'
    p.cost_limit = x[:cost_limit]
    p.status = x[:status]
    # p.user_id = @@user.id
    p.save

    @@user.id = p.user.id

    # for each x operation, if the operation exists, update it, else create it
    op_ids = operations p, x[:operations]

    puts "op_ids = #{op_ids} while plan ops = #{p.operations.collect(&:id)}"

    # for each plan operation, if it is not in x, then delete it
    p.operations.each do |pop|
      next if op_ids.member?(pop.id)
      pas = PlanAssociation.where(plan_id: p.id, operation_id: pop.id)
      pas.each(&:destroy)
      pop.destroy
      puts pop.errors.full_messages.join(', ')
    end

    # for each x wire, if the wire doesn't exist, create it
    wire_ids = if x[:wires]
                 wires p, x[:wires]
               else
                 []
               end

    # for each plan wire, if the wire is not in x, then delete it
    p.wires.each do |pwire|
      pwire.destroy unless !x[:wires] || wire_ids.member?(pwire.id)
    end

    p.layout = mod(x[:layout]).to_json
    p.save

    p.reload

    p

  end

  def self.sid(str)
    str ? str.split(':')[0] : nil
  end

  def self.map_id(rid, id)
    @@id_map ||= []
    @@id_map[rid] = id
  end

  def self.mod(m)

    mod = m

    if mod[:wires]
      mod[:wires] = mod[:wires].collect do |w|

        wire = w

        wire[:from_op] = { id: @@id_map[w[:from_op][:rid]] }  if w[:from_op]
        wire[:to_op]   = { id: @@id_map[w[:to_op][:rid]]   }  if w[:to_op]
        wire[:from]    = { record_type: 'FieldValue', id: @@id_map[w[:from][:rid]] } if w[:from][:record_type] == 'FieldValue'
        wire[:to]      = { record_type: 'FieldValue', id: @@id_map[w[:to][:rid]] }   if w[:to][:record_type] == 'FieldValue'

        wire

      end
    end

    mod[:children] = mod[:children].collect { |c| self.mod c } if mod[:children]

    mod

  end

end
