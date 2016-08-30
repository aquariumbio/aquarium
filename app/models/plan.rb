class Plan < ActiveRecord::Base

  include PlanSerializer

  attr_accessible :user_id

  has_many :plan_associations
  has_many :operations, through: :plan_associations

  def start
    gs = goals_plain
    issues = gs.collect { |g| g.issues }.flatten
    if issues.empty?
      gs.each do |goal|
        goal.recurse do |op|
          op.user_id = user_id
          if op.status == "planning"
            op.status = op.leaf? ? "pending" : "waiting"
          end
          op.save
        end
      end
      []
    else
      issues
    end
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

  def status
    s = "Under Construction"
    goals_plain.each do |g|
      if g.status != "planning"
        s = "Running"
      end
    end
    s
  end

  def select_subtree operation
    Rails.logger.info "TODO: Select the subtree"
  end

  def self.list user

    plans = Plan.includes(operations: :operation_type).where(user_id: user.id).as_json(include: { operations: { include: :operation_type } }).as_json
    op_ids = plans.collect { |p| p["operations"].collect { |o| o["id"] } }.flatten
    fvs = FieldValue.includes(:child_sample).where(parent_class: "Operation", parent_id: op_ids)

    plans.each do |plan|
      running = false
      done = true
      plan["operations"].each do |op|
        running = true if [ "pending", "waiting", "ready", "scheduled", "running" ].member? op["status"]
        done = false unless [ "done", "error" ].member? op["status"]
        op["inputs"] = []
        op["outputs"] = []        
        fvs.each do |fv|
          op["inputs"] << fv if fv["parent_id"] == op["id"] && fv["role"] == "input"
          op["outputs"] << fv if fv["parent_id"] == op["id"] && fv["role"] == "output"
        end
      end
      plan["goals"] = [ plan["operations"][0] ]
      plan["status"] = "Under Construction" if !running && !done
      plan["status"] = "Running" if running
      plan["status"] = "Completed" if done            
    end

    plans

  end

end