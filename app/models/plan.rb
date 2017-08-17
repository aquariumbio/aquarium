class Plan < ActiveRecord::Base

  include DataAssociator

  attr_accessible :user_id, :budget_id, :name, :cost_limit, :status, :layout

  has_many :plan_associations
  has_many :operations, through: :plan_associations
  belongs_to :user
  belongs_to :budget

  def start

    gs = goals_plain

    issues = gs.collect { |g| g.issues }.flatten

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

  def error msg, key=:job_crash

    operations.each do |op|
      if op.status != "done"
        op.error key, msg
      end
    end

    associate key, msg

  end

  def remove

    operations.each do |op|

      op.field_values.each do |fv|
        fv.wires_as_dest.each do |w|
          puts "deleteing wire #{w.id}"
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
    self.delete

  end

  def goals_plain
    # TODO: Make this faster. 
    operations.select { |op| op.successors.length == 0 }
  end  

  def goals
    # TODO: Make this faster. Note, fvs doesn't work, so will probably need to be some kind of SQL query.
    goals_plain.as_json(include: :operation_type, methods: :field_values)
  end

  # def status
  #   s = "Under Construction"
  #   goals_plain.each do |g|
  #     if g.status != "planning"
  #       s = "Running"
  #     end
  #   end
  #   s
  # end

  def select_subtree operation

    operation.siblings.each do |op|
      if op == operation
        op.activate
      else
        op.deactivate
      end
    end

  end

  # def self.list user

  #   plans = Plan.includes(operations: :operation_type).where(user_id: user.id).as_json(include: { operations: { include: :operation_type } }).as_json
  #   op_ids = plans.collect { |p| p["operations"].collect { |o| o["id"] } }.flatten
  #   fvs = FieldValue.includes(:child_sample).where(parent_class: "Operation", parent_id: op_ids)

  #   plans.each do |plan|
  #     running = false
  #     done = true
  #     error = false
  #     plan["operations"].each do |op|
  #       selected = op["status"] != "unplanned"
  #       running = true if [ "pending", "waiting", "ready", "scheduled", "running" ].member? op["status"]
  #       done = false unless !selected || [ "done", "error" ].member?(op["status"])
  #       error = true if op["status"] == "error"
  #       op["inputs"] = []
  #       op["outputs"] = []        
  #       fvs.each do |fv|
  #         op["inputs"] << fv if fv["parent_id"] == op["id"] && fv["role"] == "input"
  #         op["outputs"] << fv if fv["parent_id"] == op["id"] && fv["role"] == "output"
  #       end
  #     end
  #     plan["goals"] = [ plan["operations"][0] ]
  #     plan["status"] = "Under Construction" if !running && !done
  #     plan["status"] = "Running" if running
  #     plan["status"] = "Completed" if done   
  #     plan["status"] = "Error" if error      
  #   end

  #   plans

  # end

  def wires

    fvs = []

    op_ids = operations.collect { |op| op.id }
    FieldValue.where(parent_class: "Operation", parent_id: op_ids).each do |fv|
      fvs << fv.id
    end

    Wire.where(from_id: fvs).where(to_id: fvs).uniq

  end

  def relaunch

    fv_maps = []

    # Make new plan
    newplan = Plan.new user_id: user_id, budget_id: budget_id
    newplan.save

    # Make new operations from old ones
    operations.each do |op|
      newop = op.operation_type.operations.create status: 'planning', user_id: op.user_id
      op.field_values.each do |fv|
        newfv = FieldValue.new({
          name: fv.name,
          child_sample_id: fv.child_sample_id,
          value: fv.value,
          role: fv.role,
          field_type_id: fv.field_type_id,
          allowable_field_type_id: fv.allowable_field_type_id,
          parent_class: "Operation",
          parent_id: newop.id
        })
        newfv.save
        fv_maps[fv.id] = newfv.id
      end
      newplan.plan_associations.create operation_id: newop.id
    end

    wires.each do |wire|
      newwire = Wire.new from_id: fv_maps[wire.from_id] , to_id: fv_maps[wire.to_id]
      newwire.save
    end

    newplan

  end

  def costs

    labor_rate = Parameter.get_float("labor rate") 
    markup_rate = Parameter.get_float("markup rate")

    op_ids = PlanAssociation.where(plan_id: id).collect { |pa| pa.operation_id }
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
