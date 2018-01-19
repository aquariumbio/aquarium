class PlansController < ApplicationController

  before_filter :signed_in_user

  # Planner GUI

  def index
    respond_to do |format|
      format.json { render json: Plan.list(current_user).reverse }
      format.html { render layout: 'aq2' }
    end  
  end

  def create

    puts "CREATING PLAN WITH USER_ID = #{params[:user_id]}"

    if current_user.is_admin && params[:user_id] && params[:user_id] != current_user.id
      Marshall.user = User.find(params[:user_id])
    else
      Marshall.user = current_user
    end

    ActiveRecord::Base.transaction do      
      begin
        @plan = Marshall.plan params
      rescue Exception => e
        @plan = Plan.new
        @plan.errors.add :error, "Mashall failed"
        @plan.errors.add :error, e.to_s + e.backtrace[0].to_s
      end
      raise ActiveRecord::Rollback unless @plan.errors.empty?
    end

    if @plan.errors.empty?
      @plan.reload
      render json: Serialize.serialize(@plan)
    else
      render json: { errors: @plan.errors }, status: 422
    end

  end

  def update

    if current_user.is_admin && params[:user_id] && params[:user_id] != current_user.id
      Marshall.user = User.find(params[:user_id])
    else
      Marshall.user = current_user
    end

    ActiveRecord::Base.transaction do 
      begin
        @plan = Marshall.plan_update params
      rescue Exception => e
        @plan = Plan.new
        @plan.errors.add :error, e.to_s
      end
      raise ActiveRecord::Rollback unless @plan.errors.empty?
    end

    if @plan.errors.empty?
      render json: Serialize.serialize(@plan)
    else
      render json: { errors: @plan.errors }, status: 422
    end

  end

  def show
    respond_to do |format|      
      format.html { 
        redirect_to plans_url(params)
      }
      format.json { render json: Serialize.serialize(Plan.find(params[:id])) }
    end           
  end

  def operation_types
    render json: Serialize.fast_operation_types(params[:deployed_only])
  end

  # End Planner GUI

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

  def start

    plan = Plan.find(params[:id])
    plan.budget_id = params[:budget_id]
    plan.save
    
    planner = Planner.new params[:id]
    
    if planner.start
      render json: { result: "ok" }
    else
      render json: planner.errors, status: 422
    end

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


  def destroy
    plan = Plan.find(params[:id])
    plan.remove
    render json: {}
  end

  def select

    plan = Plan.find(params[:pid])
    operation = Operation.find(params[:oid])
    plan.select_subtree(operation)
    render json: plan.serialize

  end

  def replan

    render json: PlanCopier.new(params[:id]).copy

  end

  def cancel

    Plan.find(params[:id]).error(params[:msg] + " (user: #{current_user.login})",:canceled)

    render json: { result: "ok" }

  end

  def costs

    render json: Plan.find(params[:id]).costs

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
        error = e.to_s
      end

      if error

        errors << error

        ops.each do |op|
          op.plan.error "Could not start job: #{error}", :job_start
        end

      else

        begin

          ops.extend(Krill::OperationList)

          ops.each do |op|
            op.run
          end

          manager.run

        rescue Exception => e

          errors << "Bug encountered while testing: " + e.message + " at " + e.backtrace.join("\n") + ". "

        end # begin

      end # if

    end # type_ids.each

    Operation.step(plan.operations.select { |op| op.status == "waiting" || op.status == "deferred" })

    render json: { errors: errors }

  end # def debug

  def move

    Plan.where(id: params[:pids]).each do |plan|
      plan.folder = params[:folder]
      plan.save
    end

    render json: { result: "okay" }

  end

  def folders
    if current_user && current_user.is_admin && params[:user_id]
      uid = params[:user_id]
    else
      uid = current_user.id
    end
    render json: Plan.where(user_id: uid).pluck(:folder).uniq
  end

end
