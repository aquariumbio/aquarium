class OperationTypesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user  

  before_filter {
    unless current_user && current_user.is_admin
      redirect_to root_path, notice: "Administrative privileges required to access operation type definitions."
    end
  }

  def index

    respond_to do |format|
      format.json { render json: OperationType.all.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation]) }
      format.html { render layout: 'aq2' }
    end    
    
  end

  def create

    ot = OperationType.new(
      name: params[:name], category: params[:category], 
      deployed: params[:deployed], on_the_fly: params[:on_the_fly])

    ot.save

    if params[:field_types]
      params[:field_types].each do |ft|
        ot.add_new_field_type ft
      end
    end

    ["protocol", "precondition", "cost_model", "documentation"].each do |name|
      ot.new_code(name, params[name]["content"])
    end

    j = ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation])

    render json: j

  end

  def destroy

    ot = OperationType.find(params[:id])

    if ot.operations.count != 0
      render json: { error: "Operation Type #{ot.name} has associated operations." }
    elsif ot.deployed
      render json: { error: "Operation Type #{ot.name} has been deployed." }
    else
      ot.destroy
      render json: { ok: true }
    end

  end

  def code

    if params[:no_edit]

      render json: {}

    else

      ot = OperationType.find(params[:id])
      c = ot.code(params[:name])
      
      unless params[:no_edit]
        if c
          c = c.commit(params[:content])
        else
          c = ot.new_code(params[:name], params[:content])
        end
      end

      render json: c

    end

  end

  def update_from_ui data, update_fields=true

    ot = OperationType.find(data[:id])
    update_errors = []

    ActiveRecord::Base.transaction do

      ot.name = data[:name]
      ot.category = data[:category]
      ot.deployed = data[:deployed]
      ot.on_the_fly = data[:on_the_fly] 
      ot.save

      if !ot.errors.empty?
        update_errors += ot.errors.full_messages
        raise ActiveRecord::Rollback
      end

      if update_fields

        begin
          ot.update_field_types data[:field_types]
        rescue Exception => e
          update_errors << e.to_s << e.backtrace.to_s
          raise ActiveRecord::Rollback
        end

      end

    end

    ot[:update_errors] = update_errors

    ot

  end

  def update
    ot = update_from_ui params
    if ot[:update_errors].empty?
      render json: ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation])
    else
      render json: { errors: ot.update_errors }     
    end
  end

  def default
    render json: { content: File.open("lib/tasks/default.rb", "r").read }
  end

  def random

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
          render json: ops.as_json(methods: [ :field_values, :precondition_value ])
        else
          render json: { error: "One or more preconditions could not be evaluated." }
        end
        raise ActiveRecord::Rollback

      end

    rescue Exception => e
      render json: { error: e.to_s, backtrace: e.backtrace }
    end
    
  end

  def make_test_ops ot, tops

    tops.collect do |test_op|

      op = ot.operations.create status: "pending", user_id: test_op[:user_id]

      (ot.inputs + ot.outputs).each do |io|

        if io.ftype != 'sample'

          if io.choices != "" && io.choices != nil
            op.set_property io.name, io.choices.split(',').sample, io.role, true, nil
          elsif io.ftype == "number"
            op.set_property io.name, rand(100), io.role, true, nil
          elsif io.ftype == "json"
            op.set_property io.name, "{ \"message\": \"random json parameters are hard to generate\" }", io.role, true, nil
          else
            op.set_property(io.name, ["Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit" ].sample, io.role, true, nil)
          end

        elsif io.array

          fvs = test_op[:field_values].select { |fv| fv[:name] == io.name && fv[:role] == io.role }
          unless fvs.empty?
            aft = AllowableFieldType.find_by_id(fvs[0][:allowable_field_type_id])
            samples = fvs.collect { |fv|
              Sample.find_by_id(fv[:child_sample_id])
            }
            actual_fvs = op.set_property(io.name, samples, io.role,true,aft)
            raise "Nil value Error: Could not set #{fvs}" unless actual_fvs
          end

        else

          fvlist = test_op[:field_values].select { |fv| fv[:name] == io.name && fv[:role] == io.role }
          fv = fvlist[0]
          aft = AllowableFieldType.find_by_id(fv[:allowable_field_type_id])
          actual_fv = op.set_property(fv[:name], Sample.find_by_id(fv[:child_sample_id]), fv[:role],true,aft)
          raise "Nil value Error: Could not set #{fv}" unless actual_fv
          unless actual_fv.errors.empty? 
            raise "Active Record Error: Could not set #{fv}: #{actual_fv.errors.full_messages.join(', ')}"
          end 

        end

      end

      op

    end

  end

  def test

    # save the operaton
    ot = update_from_ui params, false

    if !ot[:update_errors].empty? 
      render json: { errors: ot.update_errors }
      return
    end

    # start a transaction
    ActiveRecord::Base.transaction do

      # (re)build the operations
      if params[:test_operations]
        ops = make_test_ops(OperationType.find(params[:id]), params[:test_operations])
      else
        ops = []
      end

      plans = []
      ops.each do |op|
        plan = Plan.new user_id: current_user.id, budget_id: Budget.all.first.id
        plan.save        
        plans << plan
        pa = PlanAssociation.new operation_id: op.id, plan_id: plan.id
        pa.save
      end

      if params[:use_precondition]
        logger.info "Using Precondition to filter operation types"
        ops = ops.select { |op| op.precondition_value }
      end      

      # run the protocol
      job,newops = ot.schedule(ops, current_user, Group.find_by_name('technicians'))
      error = nil

      begin
        manager = Krill::Manager.new job.id, true, "master", "master"
      rescue Exception => e
        error = e
      end

      if error

        render json: {
          error: error.message,
          backtrace: error.backtrace
        }

      else

        begin

          ops.extend(Krill::OperationList)
          ops.make(role: 'input')

          ops.each do |op|
            op.run # sets operation status to running
          end

          manager.run

          ops.each { |op| op.reload }

          # render the resulting data including the job and the operations
          render json: {
            operations: ops.as_json(methods: [:field_values,:associations]),
            plans: plans.collect { |p| p.as_json(include: :operations, methods: [:associations, :costs]) },
            job: job.reload
          }

        rescue Exception => e

          logger.error "Bug encountered while testing: " + e.message + " -- " + e.backtrace.to_s

          e.backtrace.each do |b|
            logger.error b
          end

          render json: {
            error: "Bug encountered while testing: " + e.message + " at " + e.backtrace.join("\n") + ". ",
            backtrace: e.backtrace
          }          

        end

      end

      # rollback the transaction so test data is not added to the inventory
      raise ActiveRecord::Rollback

    end   

  end

  def export
    render json: [ OperationType.find(params[:id]).export ]
  end

  def export_category

    ots = OperationType.where(category: params[:category]).collect { |ot|
      ot.export
    }

    render json: ots

  end
 
  def import

    ots = []

    begin 
      
      issues_list = params[:operation_types].collect { |x|
        OperationType.import(x.merge(deployed: false))
      }

      render json: { 
        operation_types: issues_list.collect { |issues| issues[:object_type] }.collect { |ot| 
          ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation, :timing]) 
        },
        notes: issues_list.collect { |issues| issues[:notes] }.flatten,
        inconsistencies: issues_list.collect { |issues| issues[:inconsistencies] }.flatten
      }

    rescue Exception => e

      ots.each { |ot| ot.destroy }
      render json: { error: "Rails could not import operation types: " + e.to_s + ": " + e.backtrace.to_s }

    end

  end

  def copy

    begin
      ot = OperationType.find(params[:id]).copy
      render json: { operation_type: ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation]) }
    rescue Exception => e
      render json: { error: "Could not copy operation type: " + e.to_s }
    end

  end

  def numbers

    render json: OperationType.numbers

    # ops = Operation.where(operation_type_id: params[:id])
    #                .where( "status = 'waiting' OR status = 'pending' OR status = 'scheduled' OR status = 'deferred' OR status = 'running'" )

    # pending = ops.select { |op| op.status == 'pending' }

    # pending_true = []
    # pending_false = []
    # pending.each do |op|
    #   if op.precondition_value
    #     pending_true << op
    #   else
    #     pending_false << op
    #   end
    # end
    
    # s = ops.select { |op| op.status == 'scheduled' }.length
    # r = ops.select { |op| op.status == 'running' }.length
    # w = ops.select { |op| op.status == 'waiting' }.length
    # d = ops.select { |op| op.status == 'deferred' }.length

    # render json: {
    #   pending_true: pending_true.length,
    #   pending_false: pending_false.length + w,
    #   scheduled: s,
    #   deferred: d,
    #   running: r,
    #   waiting: w
    # }

  end

  def stats
    render json: OperationType.find(params[:id]).stats
  end

end

