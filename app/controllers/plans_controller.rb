class PlansController < ApplicationController

  before_filter :signed_in_user

  def show
    respond_to do |format|
      format.html { render layout: 'browser' }
    end    
  end

  def manager
    respond_to do |format|
      format.html { render layout: 'browser' }
    end    
  end

  def sid str
    if str
      str.split(':')[0]
    else
      0
    end
  end

  def show
    render json: Plan.find(params[:id]).serialize
  end

  def start
    p = Plan.find(params[:id])
    issues = p.start
    p.reload
    render json: { plan: p.serialize, issues: issues }
  end

  def value data
     if data.class == Array
      data.collect { |str| Sample.find(sid(str)) }
    else
      Sample.find_by_id(sid(data))
    end
  end

  def plan

    ot = OperationType.find(params[:ot_id])

    operations = params[:operations].collect do |o|
      op = ot.operations.create status: "planning", user_id: current_user.id
      ot.inputs.each do |input|
        puts "========== setting #{input.name} to #{o[:fvs][input.name]}"
        op.set_input input.name, value(o[:fvs][input.name])
      end
      ot.outputs.each do |output|
        op.set_output output.name, value(o[:fvs][output.name])
      end      
      op
    end

    planner = Planner.new OperationType.all
    planner.plan_trees operations   
    planner.plan.reload
    render json: planner.plan.serialize

  end

  def index
    respond_to do |format|
      format.json { render json: Plan.list(current_user).reverse }
      format.html { render layout: 'browser' }
    end  
  end

  def destroy
    Plan.find(params[:id]).remove
    render json: {}
  end

  def select

    plan = Plan.find(params[:pid])
    operation = Operation.find(params[:oid])

    plan.select_subtree(operation)

    render json: plan.serialize

  end

  def replan

    # Find the plan
    operation = Operation.find(params[:id])
    puts "============= REPLANNING Operation #{operation.id}: #{operation.operation_type.name}"
    puts "============= FVS: #{params[:fvs]} ============="
    params[:fvs].each do |key,str|
      puts "========== SETTING #{key} to #{str} =============="
      operation.set_input(key,value(str))
     end

    # Replan the operation
    planner = Planner.new OperationType.all, operation.plan
    planner.plan_tree operation
    planner.mark_shortest operation
    planner.mark_unused operation

    # render the plan
    redirect_to plan_path(id: operation.plan.id)

  end

end