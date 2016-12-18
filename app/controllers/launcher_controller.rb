class LauncherController < ApplicationController

  before_filter :signed_in_user

  def index
    respond_to do |format|
      format.html { render layout: 'browser' }
    end
  end

  def sid str
    str ? str.split(':')[0] : 0
  end

  def operation_from form

    ot = OperationType.find(params[:operation_type][:id])
    op = ot.operations.create
    params[:field_values].each do |fv|
      field_value = op.field_values.create name: fv[:name], role: fv[:role]
      if field_value[:sample_identifier]
        field_value.child_sample_id = sid(field_value[:sample_identifier])
      else
        field_value.child_sample_id = sid(form[:routing][fv[:routing]])
      end
      field_value.save
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

end
