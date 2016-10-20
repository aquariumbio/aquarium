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
    respond_to do |format|      
      format.html { 
        redirect_to plans_url(params)
      }
      format.json { render json: Plan.find(params[:id]).serialize }
    end           
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

    errors = []

    operations = params[:operations].collect do |o|

      op = ot.operations.create status: "planning", user_id: current_user.id

      ot.inputs.each do |input|       
        if input.empty?
          op.set_input input.name, nil 
        else
          v = value(o[:fvs][input.name][:sample])
          puts "---------------- #{o[:fvs][input.name]}"
          aft = AllowableFieldType.find_by_id(o[:fvs][input.name][:aft][:id])
          op.set_input input.name, v, aft if v
          errors << "Input '#{input.name}' not specified. IO specifications should be in the form id: name." unless v
        end
      end

      ot.outputs.each do |output|
        if output.empty?
          op.set_output output.name, nil
        else
          v = value(o[:fvs][output.name][:sample])
          aft = AllowableFieldType.find_by_id(o[:fvs][output.name][:aft][:id])
          op.set_output output.name, v, aft if v
          errors << "Output '#{output.name}' not specified. IO specifications should be in the form id: name." unless v
        end
      end   

      op

    end

    if errors.empty?
      planner = Planner.new OperationType.where(deployed: true)
      planner.plan_trees operations   
      planner.plan.reload
      render json: planner.plan.serialize
    else
      render json: { errors: errors }
    end

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
    params[:fvs].each do |key,val|
      puts "========== SETTING #{key} to #{val} =============="
      aft = AllowableFieldType.find_by_id(val[:aft][:id])
      operation.set_input(key,value(val[:sample]),aft)
     end

    # Replan the operation
    planner = Planner.new(OperationType.where(deployed: true), operation.plan)
    planner.plan_tree operation
    planner.mark_shortest operation
    planner.mark_unused operation

    # render the plan
    redirect_to plan_path(id: operation.plan.id, format: :json)

  end

end