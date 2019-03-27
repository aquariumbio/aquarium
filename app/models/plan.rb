

class Plan < ActiveRecord::Base

  include DataAssociator

  attr_accessible :user_id, :budget_id, :name, :cost_limit, :status, :layout

  has_many :plan_associations
  has_many :operations, through: :plan_associations
  belongs_to :user
  belongs_to :budget

  def start

    gs = goals_plain

    issues = gs.collect(&:issues).flatten

    if issues.empty?

      operations.each do |op|

        op.start
        op.user_id = user_id
        op.save

      end

    else

      Rails.logger.info "Plan has issues: #{issues}"
      errors.add :start_plan, issues.to_s

    end

  end

  def error(msg, key = :job_crash)

    operations.each do |op|
      op.error key, msg if op.status != 'done'
    end

    associate key, msg

  end

  def remove

    operations.each do |op|

      op.field_values.each do |fv|
        fv.wires_as_dest.each do |w|
          puts "deleting wire #{w.id}"
          w.delete
        end
        fv.wires_as_source.each do |w|
          puts "deleting wire #{w.id}"
          w.delete
        end
        puts "deleted fv #{fv.id}"
        fv.delete
      end

      puts "destroying operation #{op.id}"
      op.delete

    end

    puts "destroying plan #{id}"
    delete

  end

  def goals_plain
    # TODO: Make this faster.
    operations.select { |op| op.successors.empty? }
  end

  def goals
    # TODO: Make this faster. Note, fvs doesn't work, so will probably need to be some kind of SQL query.
    goals_plain.as_json(include: :operation_type, methods: :field_values)
  end

  def select_subtree(operation)

    operation.siblings.each do |op|
      if op == operation
        op.activate
      else
        op.deactivate
      end
    end

  end

  def wires

    fvs = []

    op_ids = operations.collect(&:id)
    FieldValue.where(parent_class: 'Operation', parent_id: op_ids).each do |fv|
      fvs << fv.id
    end

    Wire.where(from_id: fvs).where(to_id: fvs).uniq

  end

  def relaunch

    fv_maps = []

    # Make new plan
    new_plan = Plan.new user_id: user_id, budget_id: budget_id
    new_plan.save

    # Make new operations from old ones
    operations.each do |op|
      new_op = op.operation_type.operations.create status: 'planning', user_id: op.user_id
      op.field_values.each do |fv|
        new_fv = FieldValue.new(
          name: fv.name,
          child_sample_id: fv.child_sample_id,
          value: fv.value,
          role: fv.role,
          field_type_id: fv.field_type_id,
          allowable_field_type_id: fv.allowable_field_type_id,
          parent_class: 'Operation',
          parent_id: new_op.id
        )
        new_fv.save
        fv_maps[fv.id] = new_fv.id
      end
      new_plan.plan_associations.create operation_id: new_op.id
    end

    wires.each do |wire|
      new_wire = Wire.new from_id: fv_maps[wire.from_id], to_id: fv_maps[wire.to_id]
      new_wire.save
    end

    new_plan

  end

  def costs

    labor_rate = Parameter.get_float('labor rate')
    markup_rate = Parameter.get_float('markup rate')

    op_ids = PlanAssociation.where(plan_id: id).collect(&:operation_id)
    ops = Operation.includes(:operation_type).find(op_ids)

    ops.collect do |op|

      begin
        c = op.nominal_cost.merge(labor_rate: labor_rate, markup_rate: markup_rate, id: op.id)
      rescue Exception => e
        c = {}
      end

      c

    end

  end

end
