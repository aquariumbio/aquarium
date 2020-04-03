# frozen_string_literal: true

require 'minitest'

class OperationTypesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def test_all
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end

  def index
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    respond_to do |format|
      format.json do
        render json: OperationType.all.as_json(methods: %i[field_types protocol precondition cost_model documentation]),
               status: :ok
      end
      format.html { render layout: 'aq2', status: :ok }
    end
  end

  def create
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    ot = OperationType.new(
      name: params[:name], category: params[:category],
      deployed: params[:deployed], on_the_fly: params[:on_the_fly]
    )

    unless ot.valid?
      if ot.errors.messages.key?(:name)
        message = "An operation type named #{ot.name} already exists."
        Rails.logger.info(message)
        render json: { error: message },
               status: :unprocessable_entity
      else
        render json: { error: 'invalid operation type' },
               status: :unprocessable_entity
      end
      return
    end

    ot.save

    if params[:field_types]
      params[:field_types].each do |ft|
        ot.add_new_field_type ft
      end
    end

    %w[protocol precondition cost_model documentation].each do |name|
      ot.new_code(name, params[name]['content'], current_user)
    end

    j = ot.as_json(methods: %i[field_types protocol precondition cost_model documentation])

    render json: j, status: :ok
  end

  def destroy
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    ot = OperationType.find(params[:id])
    if ot.operations.count != 0
      resp = { error: "Operation Type #{ot.name} has associated operations." },
             status = :unprocessable_entity
    elsif ot.deployed
      resp = { error: "Operation Type #{ot.name} has been deployed." }
      status = :unprocessable_entity
    else
      ot.destroy
      resp = { ok: true }
      status = :ok
    end
    render json: resp, status: status
  end

  def code
    if params[:no_edit]
      render json: {}, status: :ok
      return
    end

    ot = OperationType.find(params[:id])
    code_object = ot.code(params[:name])
    code_object = if code_object
                    code_object.commit(params[:content], current_user)
                  else
                    ot.new_code(params[:name], params[:content], current_user)
                  end
    render json: code_object, status: :ok
  end

  # TODO: resolve duplicate code with OperationType::simple_import in OperationTypeExport
  def update_from_ui(data, update_fields = true)
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    ot = OperationType.find(data[:id])
    update_errors = []

    ActiveRecord::Base.transaction do
      ot.name = data[:name]
      ot.category = data[:category]
      ot.deployed = data[:deployed]
      ot.on_the_fly = data[:on_the_fly]
      ot.save

      unless ot.errors.empty?
        update_errors += ot.errors.full_messages
        logger.error("Error saving operation type: #{ot.errors.full_messages}")
        raise ActiveRecord::Rollback
      end

      if update_fields
        begin
          ot.update_field_types data[:field_types]
        rescue StandardError => e
          update_errors << e.to_s << e.backtrace.to_s
          logger.error("Error updating operation type field types: #{e.backtrace}")
          raise ActiveRecord::Rollback
        end
      end
    end

    { op_type: ot, update_errors: update_errors }
  end

  def update
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    ot = update_from_ui(params)
    if ot[:update_errors].empty?
      operation_type = ot[:op_type]
      render json: operation_type.as_json(methods: %i[field_types protocol precondition cost_model documentation]),
             status: :ok
    else
      render json: { error: ot[:update_errors] },
             status: :unprocessable_entity
    end
  end

  def default
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?
    render json: { content: File.open('lib/tasks/default.rb', 'r').read },
           status: :ok
  end

  # returns serialized output from operation_type.random
  def random
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    ActiveRecord::Base.transaction do
      begin
        operation_type = OperationType.find(params[:id])
        ops = operation_type.random(params[:num].to_i)
        ops.select(&:precondition_value)
        ops_json = ops.as_json(methods: %i[field_values precondition_value])
        ops_json.each do |op|
          op['field_values'] = op['field_values'].collect(&:full_json)
        end

        if ops_json.empty?
          render json: { error: 'No operations generated', backtrace: [] },
                 status: :unprocessable_entity
        else
          render json: ops_json, status: :ok
        end
      rescue StandardError => e
        logger.error(e.message)
        e.backtrace.each do |b|
          logger.error(b)
        end
        # TODO: some errors may need backtrace
        backtrace = [] # e.backtrace || []
        render json: { error: e.message, backtrace: backtrace },
               status: :unprocessable_entity
      end
      raise ActiveRecord::Rollback
    end
  end

  # Creates test operations for a test generated by {random}.
  #
  # @param ot [OperationType] the operation type
  # @param tops [Array<Hash>] test details
  # TODO: rewrite so this deserializes output from random
  def make_test_ops(ot, tops)
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?
    return [] if tops.blank?

    tops.collect do |test_op|
      op = ot.operations.create(status: 'pending', user_id: test_op[:user_id])

      (ot.inputs + ot.outputs).each do |io|
        values = test_op[:field_values].select do |fv|
          fv[:name] == io.name && fv[:role] == io.role
        end
        next if values.empty?

        if io.array
          aft = AllowableFieldType.find_by(id: values[0][:allowable_field_type_id])
          samples = values.collect do |fv|
            Sample.find_by(id: fv[:child_sample_id])
          end
          actual_fvs = op.set_property(io.name, samples, io.role, true, aft)
          raise "Nil value Error: Could not set #{values}" unless actual_fvs
        else # io is not an array
          raise "Test Operation Error: This operation type may have illegal routing, or zero/multiple io with the same name: #{io.name} (#{io.role}#{io.array ? ', array' : ''}) of type #{io.type}" unless io.type != 'sample' || values.one?

          test_fv = values.first
          if io.sample?
            aft = AllowableFieldType.find_by(id: test_fv[:allowable_field_type_id])
            op.set_property(test_fv[:name], Sample.find_by(id: test_fv[:child_sample_id]), test_fv[:role], true, aft)
            raise "Active Record Error: Could not set #{test_fv}: #{op.errors.full_messages.join(', ')}" unless op.errors.empty?
          elsif io.number?
            op.set_property(io.name, test_fv[:value].to_f, io.role, true, nil)
          else # string or json io
            op.set_property(io.name, test_fv[:value], io.role, true, nil)
          end
        end
      end
      op
    end
  end

  def test
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    # save the operation
    ot = update_from_ui params, false
    unless ot[:update_errors].empty?
      render json: { error: ot[:update_errors] }, status: :unprocessable_entity
      return
    end
    operation_type = ot[:op_type]

    # start a transaction
    ActiveRecord::Base.transaction do

      # (re)build the operations
      begin
        operations = if params[:test_operations]
                       make_test_ops(operation_type, params[:test_operations])
                     else
                       []
                     end
      rescue StandardError => e
        logger.error(e.message)
        e.message.backtrace.each do |b|
          logger.error(b)
        end
        response = {
          error: e.message,
          backtrace: e.backtrace
        }
        render json: response, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      operations = operations.select(&:precondition_value) if params[:use_precondition]
      if operations.empty?
        response = {
          error: 'Unable to run test: no preconditions passed',
          backtrace: []
        }
        render json: response, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      test = ProtocolTestBase.new(operation_type, current_user)
      test.add_operations(operations)

      begin
        test.run

        response = {
          operations: operations.as_json(methods: %i[field_values associations]),
          plans: test.plans.collect { |p| p.as_json(include: :operations, methods: %i[associations costs]) },
          job: test.job.reload
        }
        render json: response, status: :ok
      rescue Krill::KrillSyntaxError => e
        logger.error(e.error.message)
        e.error.backtrace.each do |b|
          logger.error(b)
        end
        response = {
          error: e.error_message,
          backtrace: e.error_backtrace
        }
        render json: response, status: :unprocessable_entity
      rescue Krill::KrillError => e
        logger.error(e.error.message)
        e.error.backtrace.each do |b|
          logger.error(b)
        end
        response = {
          error: e.error_message,
          backtrace: e.error_backtrace
        }
        render json: response,
               status: :unprocessable_entity
      rescue StandardError => e
        message = e.message
        logger.error(message)
        e.backtrace.each do |b|
          logger.error(b)
        end
        response = {
          error: 'Internal error. Please report.'
        }
        render json: response,
               status: :unprocessable_entity
      end
      # rollback the transaction so test data is not added to the inventory
      raise ActiveRecord::Rollback
    end
  end

  def export
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    begin
      render json: [OperationType.find(params[:id]).export], status: :ok
      # TODO: determine what exception might be raised here
    rescue StandardError => e
      render json: { error: 'Could not export: ' + e.to_s + ', ' + e.backtrace[0] },
             status: :internal_server_error
    end
  end

  def export_category
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    begin
      ots = OperationType.where(category: params[:category]).collect(&:export)
      libs = Library.where(category: params[:category]).collect(&:export)

      render json: ots.concat(libs), status: :ok
      # TODO: determine what exceptions might be raised here
    rescue StandardError => e
      render json: { error: 'Could not export: ' + e.to_s + ', ' + e.backtrace[0] },
             status: :internal_server_error
    end
  end

  def import
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    ots = []
    error = false

    ActiveRecord::Base.transaction do

      begin
        issues_list = params[:operation_types].collect do |x|

          issues = { notes: [], inconsistencies: [] }
          notes = []

          if x.key?(:library)
            if params[:options][:resolution_method] == 'fail'
              issues = Library.import(x, current_user)
            elsif params[:options][:resolution_method] == 'rename-existing'
              libs = Library.where(name: x[:library][:name], category: x[:library][:category])
              if libs.length == 1
                libs[0].name = libs[0].name + " archived #{Time.now.to_i}"
                libs[0].category = libs[0].category + ' (old)'
                libs[0].save
                notes << "Changed name of existing Library to '#{libs[0].name}'"
                raise libs[0].errors.full_messages.join(', ') if libs[0].errors.any?
              elsif libs.length > 1
                raise "Found multiple existing operation types named #{x[:library][:name]}"
              end
              issues = Library.import(x, current_user) if libs.length <= 1
            elsif params[:options][:resolution_method] == 'skip'
              libs = Library.where(name: x[:library][:name], category: x[:library][:category])
              issues = Library.import(x, current_user) if libs.empty?
              notes << "Skipping Library #{x[:library][:name]} because a library by the same name already exists." unless libs.empty?
            else
              raise "Unknown option '#{params[:options][:resolution_method]}' for resolution method"
            end

          else

            x[:operation_type][:deployed] = params[:options][:deploy]

            if params[:options][:resolution_method] == 'fail'
              issues = OperationType.import(x, current_user)
            elsif params[:options][:resolution_method] == 'rename-existing'
              ots = OperationType.where(name: x[:operation_type][:name], category: x[:operation_type][:category])
              if ots.length == 1
                ots[0].name = ots[0].name + " archived #{Time.now.to_i}"
                ots[0].category = ots[0].category + ' (old)'
                ots[0].deployed = false
                ots[0].save
                notes << "Changed name of existing OperationType to '#{ots[0].name}'"
                raise ots.errors.full_messages.join(', ') if ots[0].errors.any?
              elsif ots.length > 1
                raise "Found multiple existing operation types named #{x[:operation_type][:name]}"
              end
              issues = OperationType.import(x, current_user) if ots.length <= 1
            elsif params[:options][:resolution_method] == 'skip'
              ots = OperationType.where(name: x[:operation_type][:name], category: x[:operation_type][:category])
              issues = OperationType.import(x, current_user) if ots.empty?
              notes << "Skipping OperationType #{x[:operation_type][:name]} because a type by the same name already exists." unless ots.empty?
            else
              raise "Unknown option '#{params[:options][:resolution_method]}' for resolution method"
            end

          end

          issues[:notes] = issues[:notes] + notes

          issues

        end

        notes = issues_list.collect { |issues| issues[:notes] }.flatten
        inconsistencies = issues_list.collect { |issues| issues[:inconsistencies] }.flatten
        error = true if inconsistencies.any?

        if error

          render json: {
            error: 'Aquarium import canceled due to inconsistencies. No changes made.',
            operation_types: issues_list.collect { |issues| issues[:object_type] }.collect do |ot|
              ot.as_json(methods: %i[field_types protocol precondition cost_model documentation timing])
            end,
            notes: notes.uniq,
            inconsistencies: inconsistencies.uniq
          }, status: :unprocessable_entity

        else

          render json: {
            operation_types: issues_list.collect { |issues| issues[:object_type] }.collect do |ot|
              ot.as_json(methods: %i[field_types protocol precondition cost_model documentation timing])
            end,
            notes: notes.uniq,
            inconsistencies: inconsistencies.uniq
          }, status: :ok

        end
        # TODO: determine what exceptions might the raised here
      rescue StandardError => e
        error = true
        logger.info e.to_s
        logger.info e.backtrace.to_s
        render json: { error: e.to_s,
                       backtrace: e.backtrace },
               status: :unprocessable_entity
      end

      raise ActiveRecord::Rollback if error

    end

  end

  def copy

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.admin?

    begin
      ot = OperationType.find(params[:id]).copy current_user
      render json: { operation_type: ot.as_json(methods: %i[field_types protocol precondition cost_model documentation]) },
             status: :ok
      # TODO: determine what exceptions might be raised here
    rescue StandardError => e
      render json: { error: 'Could not copy operation type: ' + e.to_s },
             status: :internal_server_error
    end

  end

  def numbers

    if current_user.admin?
      if params[:user_id] && params[:filter] == 'true'
        render json: OperationType.numbers(User.find(params[:user_id])),
               status: :ok
      else
        render json: OperationType.numbers,
               status: :ok
      end
    else
      render json: OperationType.numbers(current_user),
             status: :ok
    end

  end

  def deployed_with_timing

    ots = OperationType.where(deployed: true).as_json
    ot_ids = ots.collect { |ot| ot['id'] }
    timings = Timing.where(parent_id: ot_ids, parent_class: 'OperationType')

    ots.each do |ot|
      timings.each do |timing|
        ot['timing'] = timing.as_json if ot['id'] == timing.parent_id
      end
    end

    render json: ots, status: :ok

  end

  def stats
    render json: OperationType.find(params[:id]).stats, status: :ok
  end

end
