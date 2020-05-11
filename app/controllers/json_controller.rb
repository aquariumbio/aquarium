# typed: false
# frozen_string_literal: true

class JsonController < ApplicationController

  before_filter :signed_in_user

  def index
    result = JsonQueryResult.create_from(params)
    render json: result
  rescue StandardError => e
    logger.info e.inspect
    logger.info e.backtrace
    render json: { errors: e.to_s }, status: :unprocessable_entity
   end

  def upload

    u = Upload.new

    File.open(params[:files][0].tempfile) do |f|
      u.upload = f
      u.name = params[:files][0].original_filename
      u.job_id = params[:jobid] if params[:jobid]
      u.save
    end

    unless u.errors.empty?
      logger.info "ERRORS: #{u.errors.full_messages}"
      render json: { error: 'Got error' + u.errors.full_messages.to_s }
      return
    end

    render json: u.as_json(methods: :url)
  rescue StandardError => e
    logger.error("Error in upload: #{e}")
    render json: { errors: e.to_s }, status: :internal_server_error
  end

  def save

    record = if params[:id]
               Object.const_get(params[:model][:model]).find(params[:id])
             else
               Object.const_get(params[:model][:model]).new
             end

    record.attributes.each do |name, _val|
      record[name] = params[name]
    end

    begin
      record.save
    rescue ActiveRecord::RecordNotUnique => e
      render json: { error: e.to_s },
             status: :unprocessable_entity
      return
    end

    if params[:model][:model] == 'DataAssociation' && record.parent_class == 'Plan'
      plan = Plan.find(record.parent_id)
      Operation.step(plan.operations
                         .reject { |op| %w[planning done error scheduled running].member?(op.status) })
    end

    if record.errors.empty?
      render json: record
    else
      logger.into record.errors.full_messages.join(', ')
      render json: { errors: record.errors }, status: :unprocessable_entity
    end

  end

  def delete

    record = Object.const_get(params[:model][:model]).find(params[:id])

    if record.respond_to?(:may_delete) && record.may_delete(current_user)
      record.delete
      render json: record
    else
      render json: { errors: ["Insufficient permission to delete #{params[:model][:model]}"] }, status: :unprocessable_entity
    end

  end

  def sid(str)
    str ? str.split(':')[0] : 0
  end

  def items # ( sid, oid ) # This can be replaced by a call to Item.items_for sid, oid
    sample = Sample.find_by(id: params[:sid])
    ot = ObjectType.find_by(id: params[:oid])
    if sample
      # TODO: this should return an error
      unless ot
        render json: []
        return
      end

      if ot.collection_type?
        render json: Collection.parts(sample, ot).as_json(methods: :matrix)
      else
        render json: sample.items
                           .reject { |i| i.deleted? || i.object_type_id != ot.id }
                           .as_json(include: :object_type)
      end
    else
      items = Item.includes(locator: :wizard)
                  .where("object_type_id = ? AND location != 'deleted'", ot.id)
                  .limit(25)

      render json: items
    end
  rescue StandardError => e
    # TODO: verify this is dead code: find_by_id returns nil if not found
    render json: { errors: "Could not find sample: #{e}: #{e.backtrace}" }, status: :unprocessable_entity
  end

  def current
    render json: current_user.as_json(methods: :is_admin)
  end
end
