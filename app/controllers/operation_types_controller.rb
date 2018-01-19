class OperationTypesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user  

  def index

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin

    respond_to do |format|
      format.json { render json: OperationType.all.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation]) }
      format.html { render layout: 'aq2' }
    end    
    
  end

  def create

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin    

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
      ot.new_code(name, params[name]["content"], current_user)
    end

    j = ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation])

    render json: j

  end

  def destroy

   redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin    

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
          c = c.commit(params[:content],current_user)
        else
          c = ot.new_code(params[:name], params[:content],current_user)
        end
      end

      render json: c

    end

  end

  def update_from_ui data, update_fields=true

   redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin    

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

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin

    ot = update_from_ui params
    if ot[:update_errors].empty?
      render json: ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation])
    else
      render json: { errors: ot.update_errors }     
    end
  end

  def default
    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin    
    render json: { content: File.open("lib/tasks/default.rb", "r").read }
  end

  def random

   redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin    

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
          ops_json = ops.as_json(methods: [ :field_values, :precondition_value ])
          ops_json.each do |op| 
            op[:field_values] = op[:field_values].collect { |fv| fv.full_json }
          end
          render json: ops_json
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

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin    

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

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin      

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

   redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin

    begin
      render json: [ OperationType.find(params[:id]).export ]
    rescue Exception => e
      render json: { error: "Could not export: " + e.to_s + ", " + e.backtrace[0] }
    end
  end

  def export_category

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin

    begin

      ots = OperationType.where(category: params[:category]).collect { |ot|
        ot.export
      }

      render json: ots

    rescue Exception => e
      render json: { error: "Could not export: " + e.to_s + ", " + e.backtrace[0] }
    end

  end
 
  def import

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin

    ots = []
    error = false

    ActiveRecord::Base.transaction do

      begin 
        
        issues_list = params[:operation_types].collect { |x|
          OperationType.import(x.merge(deployed: false),current_user)
        }

        notes = issues_list.collect { |issues| issues[:notes] }.flatten
        inconsistencies = issues_list.collect { |issues| issues[:inconsistencies] }.flatten
        error = true if inconsistencies.any?

        notes << "Import canceled due to inconsistencies. No changes made." if inconsistencies.any?

        render json: { 
          operation_types: issues_list.collect { |issues| issues[:object_type] }.collect { |ot| 
            ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation, :timing]) 
          },
          notes: notes.uniq,
          inconsistencies: inconsistencies.uniq
        }

      rescue Exception => e

        error = true 
        render json: { error: "Rails could not import operation types: " + e.to_s + ": " + e.backtrace.to_s, issues_list: issues_list }

      end

      raise ActiveRecord::Rollback if error      

    end

  end

  def copy

    redirect_to root_path, notice: "Administrative privileges required to access operation type definitions." unless current_user.is_admin

    begin
      ot = OperationType.find(params[:id]).copy current_user
      render json: { operation_type: ot.as_json(methods: [:field_types, :protocol, :precondition, :cost_model, :documentation]) }
    rescue Exception => e
      render json: { error: "Could not copy operation type: " + e.to_s }
    end

  end

  def numbers

    if current_user.is_admin
      if params[:user_id] && params[:filter] == "true"
        render json: OperationType.numbers(User.find(params[:user_id]))
      else
        render json: OperationType.numbers
      end
    else
      render json: OperationType.numbers(current_user)
    end

  end

  def deployed_with_timing

    ots = OperationType.where(deployed: true).as_json
    ot_ids = ots.collect { |ot| ot["id"] }
    timings = Timing.where(parent_id: ot_ids, parent_class: "OperationType")
    
    ots.each do |ot|
      timings.each do |timing|
        ot["timing"] = timing.as_json if ot["id"] == timing.parent_id
      end
    end

    render json: ots

  end  

  def stats
    render json: OperationType.find(params[:id]).stats
  end

end

