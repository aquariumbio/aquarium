# frozen_string_literal: true

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

    Marshall.user = if current_user.is_admin && params[:user_id] && params[:user_id] != current_user.id
                      User.find(params[:user_id])
                    else
                      current_user
                    end

    ActiveRecord::Base.transaction do
      begin
        @plan = Marshall.plan params
      rescue Exception => e
        @plan = Plan.new
        @plan.errors.add :error, 'Mashall failed'
        @plan.errors.add :error, e.to_s + e.backtrace[0].to_s
      end
      raise ActiveRecord::Rollback unless @plan.errors.empty?
    end

    if @plan.errors.empty?
      @plan.reload
      render json: Serialize.serialize(@plan)
    else
      render json: { errors: @plan.errors }, status: :unprocessable_entity
    end

  end

  def update

    Marshall.user = if current_user.is_admin && params[:user_id] && params[:user_id] != current_user.id
                      User.find(params[:user_id])
                    else
                      current_user
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
      render json: { errors: @plan.errors }, status: :unprocessable_entity
    end

  end

  def show
    s = Time.now
    respond_to do |format|
      format.html do
        redirect_to plans_url(params)
      end
      format.json do
        p = Plan.find_by_id(params[:id])
        if p
          ps = Serialize.serialize(p)
          logger.info "Completed serialize in #{Time.now - s}s"
          render json: ps
          logger.info "Completed show in #{Time.now - s}s"
        else
          render json: { errors: "Could not find plan with id #{params[:id]}" }, status: :not_found
        end
      end
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

  def sid(str)
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
      render json: { result: 'ok' }
    else
      render json: planner.errors, status: :unprocessable_entity
    end

  end

  def value(data)
    if data.class == Array
      data.collect { |str| Sample.find(sid(str)) }
    else
      Sample.find_by_id(sid(data))
    end
  end

  def routing_value(route)

    if route.class == String
      Sample.find_by_id(sid(route))
    else
      route.keys.collect { |k| Sample.find_by_id(sid(route[k])) }
    end

  end

  def route_name(r)
    r || 'null'
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

    Plan.find(params[:id]).error(params[:msg] + " (user: #{current_user.login})", :canceled)

    render json: { result: 'ok' }

  end

  def costs

    render json: Plan.find(params[:id]).costs

  end

  def debug
    plan = Plan.find(params[:id])
    errors = DebugEngine.debug_plan(plan)
    render json: { errors: errors }
  rescue ActiveRecord::RecordNotFound => e
    # raise "Error: plan #{params[:id]} not found"
    # TODO: change to AqResponse ??
    render json: { errors: [e] }
  end # def debug

  def move

    Plan.where(id: params[:pids]).each do |plan|
      plan.folder = params[:folder]
      plan.save
    end

    render json: { result: 'okay' }

  end

  def folders
    uid = if current_user && current_user.is_admin && params[:user_id]
            params[:user_id]
          else
            current_user.id
          end
    render json: Plan.where(user_id: uid).pluck(:folder).uniq
  end

end
