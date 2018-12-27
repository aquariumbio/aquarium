class OperationTypesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def test_all
    respond_to do |format|
      format.html { render layout: 'aq2' }
    end
  end

  def index

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    respond_to do |format|
      format.json do
        render json: OperationType.all.as_json(methods: %i[field_types protocol precondition cost_model documentation]),
               status: :ok
      end
      format.html { render layout: 'aq2', status: :ok }
    end

  end

  def create

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

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

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    ot = OperationType.find(params[:id])

    if ot.operations.count != 0
      render json: { error: "Operation Type #{ot.name} has associated operations." },
             status: :unprocessable_entity
    elsif ot.deployed
      render json: { error: "Operation Type #{ot.name} has been deployed." },
             status: :unprocessable_entity
    else
      ot.destroy
      render json: { ok: true }, status: :ok
    end

  end

  def code

    if params[:no_edit]

      render json: {}, status: :ok

    else

      ot = OperationType.find(params[:id])
      c = ot.code(params[:name])

      unless params[:no_edit]
        c = if c
              c.commit(params[:content], current_user)
            else
              ot.new_code(params[:name], params[:content], current_user)
            end
      end

      render json: c, status: :ok

    end

  end

  def update_from_ui(data, update_fields = true)

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

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
        rescue Exception => e
          update_errors << e.to_s << e.backtrace.to_s
          logger.error("Error updating operation type field types: #{e.backtrace}")
          raise ActiveRecord::Rollback
        end

      end

    end

    { op_type: ot, update_errors: update_errors }

  end

  def update

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    ot = update_from_ui params
    if ot[:update_errors].empty?
      operation_type = ot[:op_type]
      render json: operation_type.as_json(methods: %i[field_types protocol precondition cost_model documentation]),
             status: :ok
    else
      render json: { errors: ot[:update_errors] },
             status: :unprocessable_entity
    end
  end

  def default
    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin
    render json: { content: File.open('lib/tasks/default.rb', 'r').read },
           status: :ok
  end

  def random

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    ops_json = []

    begin
      ActiveRecord::Base.transaction do

        ops = OperationType.find(params[:id]).random(params[:num].to_i)

        error = false

        precondition_errors = ops.select do |op|
          begin
            op.precondition_value
          rescue Exception => e
            error = true
          end
        end

        if !error
          ops_json = ops.as_json(methods: %i[field_values precondition_value])
          ops_json.each do |op|
            op["field_values"] = op["field_values"].collect(&:full_json)
          end
          render json: ops_json, status: :ok
        else
          render json: { error: 'One or more preconditions could not be evaluated.' },
                 status: :unprocessable_entity
        end
        raise ActiveRecord::Rollback

      end
    rescue Exception => e
      render json: { error: e.to_s, backtrace: e.backtrace },
             status: :unprocessable_entity
    end

  end

  def make_test_ops(ot, tops)

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    tops.collect do |test_op|

      op = ot.operations.create status: 'pending', user_id: test_op[:user_id]

      (ot.inputs + ot.outputs).each do |io|
        test_fvs = test_op[:field_values].select { |fv| fv[:name] == io.name && fv[:role] == io.role }
        if io.array && !test_fvs.empty?
          aft = AllowableFieldType.find_by_id(test_fvs[0][:allowable_field_type_id])
          samples = test_fvs.collect do |fv|
            Sample.find_by_id(fv[:child_sample_id])
          end
          actual_fvs = op.set_property(io.name, samples, io.role, true, aft)
          raise "Nil value Error: Could not set #{test_fvs}" unless actual_fvs
        else # io is not an array
          raise "Test Operation Error: This operation type may have illegal routing, or zero/multiple io with the same name: #{io.name} (#{io.role}#{io.array ? ', array' : ''}) of type #{io.ftype}" unless io.ftype != 'sample' || test_fvs.one?
          test_fv = test_fvs.first
          if io.ftype == 'sample'
            aft = AllowableFieldType.find_by_id(test_fv[:allowable_field_type_id])
            actual_fv = op.set_property(test_fv[:name], Sample.find_by_id(test_fv[:child_sample_id]), test_fv[:role], true, aft)
            raise "Nil value Error: Could not set #{test_fv}" unless actual_fv
            raise "Active Record Error: Could not set #{test_fv}: #{actual_fv.errors.full_messages.join(', ')}" unless actual_fv.errors.empty?
          elsif io.ftype == 'number'
            op.set_property io.name, test_fv[:value].to_f, io.role, true, nil
          else # string or json io
            op.set_property io.name, test_fv[:value], io.role, true, nil
          end
        end
      end
      op
    end
  end

  def test

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    # save the operaton
    ot = update_from_ui params, false

    unless ot[:update_errors].empty?
      render json: { errors: ot[:update_errors] }, status: :unprocessable_entity
      return
    end

    # start a transaction
    ActiveRecord::Base.transaction do

      # (re)build the operations
      begin
        ops = if params[:test_operations]
                make_test_ops(OperationType.find(params[:id]), params[:test_operations])
              else
                []
              end
      rescue Exception => e 
        render json: { errors: [e.to_s] }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
        return        
      end

      plans = []
      ops.each do |op|
        plan = Plan.new user_id: current_user.id, budget_id: Budget.all.first.id
        plan.save
        plans << plan
        pa = PlanAssociation.new operation_id: op.id, plan_id: plan.id
        pa.save
      end

      ops = ops.select(&:precondition_value) if params[:use_precondition]

      # run the protocol
      operation_type = ot[:op_type]
      job, newops = operation_type.schedule(ops, current_user, Group.find_by_name('technicians'))
      error = nil

      begin
        manager = Krill::Manager.new job.id, true, 'master', 'master'
      rescue Exception => e
        error = e
      end

      if error
        render json: {
          error: error.message,
          backtrace: error.backtrace
        },
               status: :unprocessable_entity

      else
        begin
          ops.extend(Krill::OperationList)
          ops.make(role: 'input')

          ops.each(&:run)

          manager.run

          ops.each(&:reload)

          # render the resulting data including the job and the operations
          render json: {
            operations: ops.as_json(methods: %i[field_values associations]),
            plans: plans.collect { |p| p.as_json(include: :operations, methods: %i[associations costs]) },
            job: job.reload
          },
                 status: :ok
        rescue Exception => e
          logger.error 'Bug encountered while testing: ' + e.message + ' -- ' + e.backtrace.to_s

          e.backtrace.each do |b|
            logger.error b
          end

          render json: {
            error: 'Bug encountered while testing: ' + e.message + ' at ' + e.backtrace.join("\n") + '. ',
            backtrace: e.backtrace
          },
                 status: :unprocessable_entity
        end

      end

      # rollback the transaction so test data is not added to the inventory
      raise ActiveRecord::Rollback

    end

  end

  def export

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    begin
      render json: [OperationType.find(params[:id]).export], status: :ok
    rescue Exception => e
      render json: { error: 'Could not export: ' + e.to_s + ', ' + e.backtrace[0] },
             status: :internal_server_error
    end
  end

  def export_category

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    begin
      ots = OperationType.where(category: params[:category]).collect(&:export)
      libs = Library.where(category: params[:category]).collect(&:export)

      render json: ots.concat(libs), status: :ok
    rescue Exception => e
      render json: { error: 'Could not export: ' + e.to_s + ', ' + e.backtrace[0] },
             status: :internal_server_error
    end

  end

  def import

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    ots = []
    error = false

    ActiveRecord::Base.transaction do

      begin

        issues_list = params[:operation_types].collect do |x|

          issues = { notes: [], inconsistencies: [] }
          notes = []

          if x.has_key?(:library)
            if params[:options][:resolution_method] == 'fail'
              issues = Library.import(x, current_user)
            elsif params[:options][:resolution_method] == 'rename-existing'
              libs = Library.where(name: x[:library][:name], category: x[:library][:category])
              if libs.length == 1
                libs[0].name = libs[0].name + " archived #{Time.now.to_i}"
                libs[0].category = libs[0].category + " (old)"
                libs[0].save
                notes << "Changed name of existing Library to '#{libs[0].name}'"
                raise libs[0].errors.full_messages.join(", ") if libs[0].errors.any?              
              elsif libs.length > 1
                raise "Found multiple existing operation types named #{x[:library][:name]}"
              end
              issues = Library.import(x, current_user) if libs.length <= 1
            elsif params[:options][:resolution_method] == 'skip'
              libs = Library.where(name: x[:library][:name], category: x[:library][:category])
              issues = Library.import(x, current_user) if libs.length == 0
              notes << "Skipping Library #{x[:library][:name]} because a library by the same name already exists." if libs.length > 0
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
                ots[0].category = ots[0].category + " (old)"                
                ots[0].deployed = false
                ots[0].save
                notes << "Changed name of existing OperationType to '#{ots[0].name}'"
                raise ots.errors.full_messages.join(", ") if ots[0].errors.any?
              elsif ots.length > 1
                raise "Found multiple existing operation types named #{x[:operation_type][:name]}"
              end
              issues = OperationType.import(x, current_user) if ots.length <= 1
            elsif params[:options][:resolution_method] == 'skip'
              ots = OperationType.where(name: x[:operation_type][:name], category: x[:operation_type][:category])
              issues = OperationType.import(x, current_user) if ots.length == 0
              notes << "Skipping OperationType #{x[:operation_type][:name]} because a type by the same name already exists." if ots.length > 0
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

      rescue Exception => e
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

    redirect_to root_path, notice: 'Administrative privileges required to access operation type definitions.' unless current_user.is_admin

    begin
      ot = OperationType.find(params[:id]).copy current_user
      render json: { operation_type: ot.as_json(methods: %i[field_types protocol precondition cost_model documentation]) },
             status: :ok
    rescue Exception => e
      render json: { error: 'Could not copy operation type: ' + e.to_s },
             status: :internal_server_error
    end

  end

  def numbers

    if current_user.is_admin
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
