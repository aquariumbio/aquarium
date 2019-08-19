namespace :data do

  require 'json'

  # Rake task to serialize all of the plans in the database
  task extract_plan: :environment do
    plans = Plan.all.collect do |plan|
      convert_plan(plan)
    end
    File.open('plans.json', 'w') { |file| file << JSON.pretty_generate(plans) }
  end

  def convert_plan(plan)
    plan_object = plan.as_json(
      except: %i[budget_id cost_limit folder layout],
    )
    plan_object[:operations] = plan.operations.collect do |op|
      convert_operation(op)
    end
    plan_object[:wires] = plan.wires.collect do |wire|
      convert_wire(wire)
    end

    plan_object
  end

  def convert_operation(operation)
    op_object = operation.as_json(
      only: :id
    )
    op_object[:inputs] = operation.inputs.collect do |input|
      convert_field_value(input)
    end
    op_object[:outputs] = operation.outputs.collect do |output|
      convert_field_value(output)
    end
    op_object
  end

  def convert_field_value(field_value)
    value_object = field_value.as_json(
      only: [:id, :created_at, :updated_at, :name]
    )
    if field_value.value
      value_object[:value] = field_value.value.as_json
    end
    if field_value.child_item
      value_object[:item] = field_value.child_item.as_json(
        only: [:id]
      )
      value_object[:sample] = field_value.child_sample.as_json
    end

    value_object
  end

  def convert_wire(wire)
    wire_object = {}
    wire_object[:from] = {
      operation: wire.from_op.id,
      output: wire.from_id
    }
    wire_object[:to] = {
      operation: wire.to_op.id,
      input: wire.to_id
    }

    wire_object
  end

end
