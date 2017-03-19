class LauncherController < ApplicationController

  before_filter :signed_in_user

  def index
    respond_to do |format|
      format.html { render layout: 'browser' }
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
        raise field_value.errors.full_messages.join(", ")    
      end

    end

    return op

  end

  def cost

    ActiveRecord::Base.transaction do     

      begin
        op = operation_from(params)
        c = op.nominal_cost
        render json: { cost: c[:materials] + c[:labor] * Parameter.get_float("labor rate") }
      rescue Exception => e
        render json: { errors: e.to_s }
      end

      raise ActiveRecord::Rollback

    end

  end

  def submit

    ActiveRecord::Base.transaction do    

      plan = current_user.plans.create

      unless plan.errors.empty?
        render json: { errors: plan.errors.full_messages.join(", ") }, status: 422        
        raise ActiveRecord::Rollback       
      end

      params[:operations].each do |form_op|
        begin
          op = operation_from(form_op)
          op.associate_plan plan
          op.save
          unless op.errors.empty?
            render json: { errors: op.errors.full_messages.join(", ") }, status: 422        
            raise ActiveRecord::Rollback                   
          end
        rescue Exception => e
          render json: { errors: e.to_s + " " + e.backtrace[0].to_s }, status: 422        
          raise ActiveRecord::Rollback       
        end
      end

      plan.operations.each do |op|
        op.field_values.each do |fv|
          puts "A: #{fv.id}: #{fv.child_item_id}"
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
            fv.child_item_id = nil
            fv.save
          end
        end
      end

      plan.operations.each do |op|
        op.field_values.each do |fv|
          puts "B: #{fv.id}: #{fv.child_item_id}"
        end
      end      

      plan.start

      plan.operations.each do |op|
        op.field_values.each do |fv|
          puts "C: #{fv.id}: #{fv.child_item_id}"
        end
      end

      if plan.errors.empty?
        render json: plan.as_json(include: { operations: { include: :operation_type, methods: [ 'field_values' ] } } )
      else
        render json: { errors: "Could not start plan. " + plan.errors.full_messages.join(", ") }, status: 422        
        raise ActiveRecord::Rollback
      end

    end

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
      plans: plans.reverse.as_json(include: { operations: { include: :operation_type } } ),
      field_values: field_values,
      num_plans: Plan.where(user_id: current_user.id).count
    }

  end

end
