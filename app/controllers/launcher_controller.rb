class LauncherController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end

  def sid str
    str ? str.split(':')[0] : nil
  end

  def map_id rid, id
    @id_map ||= []
    @id_map[rid] = id
  end

  def operation_from form

    ot = OperationType.find(form[:operation_type][:id])
    op = ot.operations.create status: "planning", user_id: @user.id

    form[:field_values].each do |fv|

      if fv[:sample_identifier]
        sid = sid(fv[:sample_identifier])
      else
        sid = sid(form[:routing][fv[:routing]])
      end

      ft = ot.type(fv[:name],fv[:role])

      item = ( fv[:role] == 'input' && fv[:selected_item] ) ? fv[:selected_item] : nil

      if fv[:role] == 'input' && fv[:selected_item]

        if fv[:selected_item][:collection]
          item = fv[:selected_item][:collection]
          row = fv[:selected_row]
          column = fv[:selected_column]
        else
          item = fv[:selected_item]
          row = nil
          column = nil  
        end
      else
        item = nil
      end

      field_value = op.field_values.create(
        name: fv[:name], 
        role: fv[:role], 
        field_type_id: ft.id,
        child_sample_id: sid,
        child_item_id: item ? item[:id] : nil,
        allowable_field_type_id: fv[:aft_id],
        row: item ? row : nil,
        column: item ? column : nil,
        value: fv[:value]
      )

      map_id fv[:rid], field_value.id

      unless field_value.errors.empty?
        raise ot.name + " operation: " + field_value.errors.full_messages.join(", ")
      end

    end

    return op

  end

  def estimate

    @user = current_user

    costs = []
    labor_rate = Parameter.get_float("labor rate") 
    markup = Parameter.get_float("markup rate")
    error = nil
    messages = []
    
    ActiveRecord::Base.transaction do 

      begin
        plan = Plan.find(params[:id])
      rescue Exception => e
        error = e.to_s
        raise ActiveRecord::Rollback
      end

      costs = plan.operations.collect do |op|

        c = {}

        begin
          c = op.nominal_cost.merge(labor_rate: labor_rate, markup_rate: markup, id: op.id)
        rescue Exception => e
          c = { error: e.to_s + e.backtrace[0] }
        end

        c

      end

      raise ActiveRecord::Rollback

    end

    if error
      render json: { errors: error }
    else
      render json: { costs: costs, messages: messages }
    end

  end

  def plan_from params

    plan = @user.plans.create
    @id_map = {}

    unless plan.errors.empty?
      raise plan.errors.full_messages.join(", ")
    end

    params[:operations].each do |form_op|
      begin
        op = operation_from(form_op)
        op.associate_plan plan
        op.save
        @id_map[op.id] = form_op[:rid]
        unless op.errors.empty?
          raise op.errors.full_messages.join(", ")
        end
      rescue Exception => e
        raise e.to_s
      end
    end

    if params[:wires]
      params[:wires].each do |form_wire|
        wire = Wire.new({
          from_id: @id_map[form_wire[:from][:rid]], 
          to_id: @id_map[form_wire[:to][:rid]],
          active: true
        })
        wire.save
        unless wire.errors.empty? 
          raise wire.errors.full_messages.join(", ")
        end
        wire.to_op.field_values.each do |fv| # remove inputs from non-leaves
          if fv.child_item_id
            fv.child_item_id = nil
            fv.save
          end
        end
      end
    end

    messages = []

    if params[:optimize]
      messages << "Looking for like operations."
      opts = PlanOptimizer.new(plan).optimize 
      messages = messages + opts if opts.any?
      messages << "No similar operations found." unless opts.any?
    end

    return [ plan, messages ]

  end

  def submit

    @user = params[:user_id] ? User.find(params[:user_id]) : current_user

    ActiveRecord::Base.transaction do    

      if params[:user_budget_association]
        uba = UserBudgetAssociation.find params[:user_budget_association][:id]
      else
        render json: { errors: "No budget specified" }
        raise ActiveRecord::Rollback                
      end

      if !( current_user.is_admin || ( @user.id == uba.user_id && uba.budget.spent_this_month(@user.id) < uba.quota ) )
        render json: { errors: "User #{current_user.login} not authorized or overspent for budget #{uba.budget.name}"}, status: 422
        raise ActiveRecord::Rollback        
      end

      begin
        plan,messages = plan_from params
      rescue Exception => e
        render json: { errors: e }
        raise ActiveRecord::Rollback
      end

      plan.budget_id = uba.budget.id
      plan.save

      plan.start

      plan.operations.each do |op|
        op.reload
      end

      if plan.errors.empty?
        render json: plan.as_json(include: { operations: { include: :operation_type, methods: [ 'field_values' ] } } )
      else
        render json: { errors: "Could not start plan. " + plan.errors.full_messages.join(", ") }, status: 422        
        raise ActiveRecord::Rollback
      end

    end

  end

  def relaunch
    plan = Plan.find(params[:id])
    newplan = plan.relaunch
    issues = newplan.start
    newplan.reload
    render json: { 
      plan: newplan.as_json(include: { operations: { include: :operation_type, methods: [ 'field_values' ] } } ),
      issues: issues 
    }
  end

  def plans

    user = params[:user_id] ? User.find(params[:user_id]) : current_user

    if params[:plan_id]

      if current_user.id == user.id || current_user.is_admin

        plans = Plan
          .includes(operations: :operation_type)
          .where(id: params[:plan_id])

      else

        plans = []

      end

    else

      plans = Plan
        .includes(operations: [ :operation_type, job_associations: :job ])
        .where(user_id: user.id, status: nil, folder: params[:folder])
        .order('created_at DESC')
        .limit(20)
        .offset(params[:offset] || 0)

    end

    oids = plans.collect { |p| p.operations.collect { |o| o.id } }.flatten

    field_values = FieldValue
      .includes(
        :child_sample, 
        :wires_as_dest,
        :wires_as_source, 
        field_type: { allowable_field_types: [ :sample_type, :object_type ] }
        )
      .where(parent_class: "Operation", parent_id: oids)

    # serialized_plans = plans.reverse.as_json(include: [ :user, operations: ] ).as_json

    serialized_plans = plans.collect do |plan|
      serialized_plan = plan.as_json(include: :user)
      serialized_plan["operations"] = plan.operations.collect do |op|
        serialzed_op = op.as_json(include: [ :operation_type, job_associations: { include: :job }])
        serialzed_op["jobs"] = op.job_associations.collect { |ja| ja.job }
        serialzed_op
      end
      serialized_plan
    end

    render json: { 
      plans: serialized_plans.reverse,
      field_values: field_values,
      num_plans: params[:plan_id] ? 1 : Plan.where(user_id: user.id).count
    }

  end

  def spent 

    b = Budget.find(params[:id])
    uid = current_user.id

    render json: { total: b.spent(uid), this_month: b.spent_this_month(uid) }

  end  

end
