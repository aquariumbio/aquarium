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

  def routing_value route

    if route.class == String
      Sample.find_by_id(sid(route))
    else
      route.keys.collect { |k| Sample.find_by_id(sid(route[k]))}      
    end

  end

  def route_name r
    r ? r : "null"
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
          v = routing_value o[:routing][route_name(input.routing)]
          aft = AllowableFieldType.find_by_id(o[:form_inputs][input.name][:aft][:id])
          op.set_input input.name, v, aft if v
          errors << "Input '#{input.name}' not specified. IO specifications should be in the form id: name." unless v
        end
      end

      ot.outputs.each do |output|
        if output.empty?
          op.set_output output.name, nil
        else
          v = routing_value o[:routing][route_name(output.routing)]
          aft = AllowableFieldType.find_by_id(o[:form_outputs][output.name][:aft][:id])
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

    routes = {}
    params[:operation_type][:inputs].each { |i| routes[i[:name]] = i[:routing] }

    params[:form_inputs].each do |key,val|
      aft = AllowableFieldType.find_by_id(val[:aft][:id])
      v = routing_value params[:routing][route_name(routes[key])]
      operation.set_input(key,v,aft)
    end

    # Replan the operation
    planner = Planner.new(OperationType.where(deployed: true), operation.plan)
    planner.plan_tree operation
    planner.mark_shortest operation
    planner.mark_unused operation

    # render the plan
    redirect_to plan_path(id: operation.plan.id, format: :json)

  end

  def cancel

    Plan.find(params[:id]).error(params[:msg] + " (user: #{current_user.login})",:canceled)

    render json: { result: "ok" }

  end

  def debug

    plan = Plan.find(params[:id])
    errors = []

    # find all pending operations
    pending = plan.operations.select { |o| o.status == 'pending' && o.precondition_value }

    # group them by operation type
    type_ids = pending.collect { |op| op.operation_type_id }.uniq

    # batch each group and run a job
    type_ids.each do |ot_id|

      ops = pending.select { |op| op.operation_type_id == ot_id }

      job,newops = OperationType.find(ot_id)
        .schedule(ops, current_user, Group.find_by_name('technicians'))

      error = nil

      job.user_id = current_user.id
      job.save

      begin
        manager = Krill::Manager.new job.id, true, "master", "master"
      rescue Exception => e
        error = e
      end

      if error

        errors << error

      else

        begin

          ops.extend(Krill::OperationList)

          ops.each do |op|
            op.set_status "running"
          end

          manager.run

        rescue Exception => e

          errors << "Bug encountered while testing: " + e.message + " at " + e.backtrace.join("\n") + ". "

        end # begin

      end # if

    end # type_ids.each

    Operation.step(plan.operations.select { |op| op.status == "waiting" })

    render json: { errors: errors }

  end # def debug

end
