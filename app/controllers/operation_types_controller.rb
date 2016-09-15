class OperationTypesController < ApplicationController

  before_filter :signed_in_user

  before_filter {
    unless current_user && current_user.is_admin
      redirect_to root_path, notice: "Administrative privileges required to access operation type definitions."
    end
  }

  def index

    respond_to do |format|
      format.json { render json: OperationType.all.as_json(methods: [:field_types, :protocol, :cost_model, :documentation]) }
      format.html { render layout: 'browser' }
    end    
    
  end

  def add_field_types ot, fts

    if fts
      fts.each do |ft|
        if ft[:allowable_field_types]
          sample_type_names = ft[:allowable_field_types].collect { |aft| 
            puts "====== #{aft} ======"
            raise "Sample type not definied by browser for #{ft[:name]}: #{ft}" unless SampleType.find_by_name(aft[:sample_type][:name])
            aft[:sample_type][:name]
          }
          container_names =  ft[:allowable_field_types].collect { |aft| 
            raise "Object type not definied by browser for #{ft[:name]}: #{ft}!" unless ObjectType.find_by_name(aft[:object_type][:name])
            aft[:object_type][:name]
          }          
        else
          sample_type_names = []
          container_names = []
        end
        ot.add_io ft[:name], sample_type_names, container_names, ft[:role], array: ft[:array], part: ft[:part]
      end
    end

  end

  def create

    ot = OperationType.new name: params[:name]
    ot.save
    add_field_types ot, params[:field_types]     

    ["protocol", "cost_model", "documentation"].each do |name|
      ot.new_code(name, params[name]["content"])
    end

    render json: ot.as_json(methods: [:field_types, :protocol, :cost_model, :documentation])

  end

  def code

    ot = OperationType.find(params[:id])

    c = ot.code(params[:name])
    
    if c
      logger.info "Found code: #{c.inspect}"
      c = c.commit(params[:content])
    else
      logger.info "Making new code"      
      c = ot.new_code(params[:name], params[:content])
      logger.info "  ==> New code: #{c.inspect}"      
    end

    render json: c

  end

  def update_from_ui data

    ot = OperationType.find(data[:id])
    ot.name = data[:name]
    ot.save

    ot.field_types.each do |ft| 
      ft.destroy
    end

    add_field_types ot, data[:field_types]

    ot

  end

  def update
    ot = update_from_ui params
    render json: ot.as_json(methods: [:field_types, :protocol, :cost_model, :documentation])
  end

  def default
    render json: { content: File.open("lib/tasks/default.rb", "r").read }
  end

  def random
    ops_json = []
    ActiveRecord::Base.transaction do
      ops = OperationType.find(params[:id]).random(params[:num].to_i)
      render json: ops.as_json(methods: :field_values)
      raise ActiveRecord::Rollback
    end
    
  end

  def test

    # save the operaton
    update_from_ui params

    # start a transaction
    ActiveRecord::Base.transaction do

      # (re)build the operations
      ot = OperationType.find(params[:id])
      ops = []
      params[:test_operations].each do |test_op|
        op = ot.operations.create status: "ready", user_id: test_op[:user_id]
        test_op[:field_values].each do |fv|
          op.set_property(fv[:name], Sample.find(fv[:child_sample_id]),fv[:role])
        end
        ops << op
      end

      # run the protocol
      job = ot.schedule(ops, current_user, Group.find_by_name('technicians'))
      manager = Krill::Manager.new job.id, true, "master", "master"

      ops.each do |op|
        op.set_status "running"
      end      

      manager.run

      ops.each { |op| op.reload }

      # render the resulting data including the job and the operations
      render json: {
        operations: ops.as_json(methods: [:field_values,:associations]),
        job: job.reload
      }

      # rollback the transaction
      raise ActiveRecord::Rollback

    end   

  end

end

