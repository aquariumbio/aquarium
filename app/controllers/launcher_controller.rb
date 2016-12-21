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

      field_value = op.field_values.create(
        name: fv[:name], 
        role: fv[:role], 
        field_type_id: ft.id,
        child_sample_id: sid,
        child_item_id: fv[:item] ? fv[:item][:id] : nil
      )

      unless field_value.errors.empty?
        raise field_value.errors.full_messages.join(", ")    
      end

    end

    return op

  end

  def cost

    ActiveRecord::Base.transaction do

      op = operation_from(params)

      begin
        c = op.nominal_cost
        render json: { cost: c[:materials] + c[:labor] * Parameter.get_float("labor rate") }
      rescue Exception => e
        render json: { errors: e.to_s }, status: 422
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
          render json: { errors: e.to_s }, status: 422        
          raise ActiveRecord::Rollback       
        end
      end

      plan.start

      if plan.errors.empty?
        render json: plan.as_json(methods: [ 'status' ] )
      else
        render json: { errors: "Could not start plan. " + plan.errors.full_messages.join(", ") }, status: 422        
        raise ActiveRecord::Rollback
      end

    end

  end

end
