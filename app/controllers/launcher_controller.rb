class LauncherController < ApplicationController

  before_filter :signed_in_user

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
    op = ot.operations.create status: "planning", user_id: current_user.id

    form[:field_values].each do |fv|

      if fv[:sample_identifier]
        sid = sid(fv[:sample_identifier])
      else
        sid = sid(form[:routing][fv[:routing]])
      end

      ft = ot.type(fv[:name],fv[:role])

      item = ( fv[:role] == 'input' && fv[:selected_item] ) ? fv[:selected_item] : nil

      field_value = op.field_values.create(
        name: fv[:name], 
        role: fv[:role], 
        field_type_id: ft.id,
        child_sample_id: sid,
        child_item_id: item ? item[:id] : nil,
        allowable_field_type_id: fv[:aft_id],
        row: item ? item[:selected_row] : nil,
        column: item ? item[:selected_column] : nil,
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

    costs = []
    labor_rate = Parameter.get_float("labor rate") 
    markup = Parameter.get_float("markup rate")
    error = nil
    
    ActiveRecord::Base.transaction do 

      begin
        plan = plan_from params
      rescue Exception => e
        error = e.to_s
        raise ActiveRecord::Rollback
      end

      costs = plan.operations.collect do |op|

        c = {}

        begin
          c = op.nominal_cost.merge(labor_rate: labor_rate, markup_rate: markup, rid: @id_map[op.id])
        rescue Exception => e
          c = { error: e.to_s }
        end

        c

      end

      raise ActiveRecord::Rollback

    end

    if error
      render json: { errors: error }
    else
      render json: costs
    end

  end

  def plan_from params

    plan = current_user.plans.create
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
        wire.to_op.field_values.each do |fv| # remove inputs from non-leaves
          if fv.child_item_id
            fv.child_item_id = nil
            fv.save
          end
        end
      end
    end

    return plan

  end

  def submit

    ActiveRecord::Base.transaction do    

      if params[:user_budget_association]
        uba = UserBudgetAssociation.find params[:user_budget_association][:id]
      else
        render json: { errors: "No budget specified" }
        raise ActiveRecord::Rollback                
      end

      if current_user.id != uba.user_id || uba.budget.spent_this_month(current_user.id) >= uba.quota
        puts "User #{current_user.login} not authorized or overspent for budget #{uba.budget.name}"
        render json: { errors: "User #{current_user.login} not authorized or overspent for budget #{uba.budget.name}"}, status: 422
        raise ActiveRecord::Rollback        
      end

      begin
        plan = plan_from params
      rescue Exception => e
        render json: { errors: e }
        raise ActiveRecord::Rollback
      end

      plan.budget_id = uba.budget.id
      plan.save

      plan.operations.each do |op|
        puts "Controller: Starting op #{op.id}: #{op.field_values.collect { |fv| [fv.name,fv.child_item_id]}.join(', ')}"
      end

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

    plans = Plan
      .includes(operations: :operation_type)
      .where(user_id: current_user.id)
      .order('created_at DESC')
      .limit(15)
      .offset(params[:offset] || 0)

    oids = plans.collect { |p| p.operations.collect { |o| o.id } }.flatten
    field_values = FieldValue
      .includes(
        :child_sample, 
        :wires_as_dest, 
        :wires_as_source, 
        field_type: { allowable_field_types: [ :sample_type, :object_type ] }
        )
      .where(parent_class: "Operation", parent_id: oids)

    render json: { 
      plans: plans.reverse.as_json(include: { operations: { include: :operation_type, methods: :jobs } } ),
      field_values: field_values,
      num_plans: Plan.where(user_id: current_user.id).count
    }

  end

  def spent 

    b = Budget.find(params[:id])
    uid = current_user.id

    render json: { total: b.spent(uid), this_month: b.spent_this_month(uid) }

  end  

end
