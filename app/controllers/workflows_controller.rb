class WorkflowsController < ApplicationController

  before_filter :signed_in_user

  # GET /workflows
  # GET /workflows.json
  def index

    @workflows = Workflow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflows.collect { |wf| 
          wf[:form] = wf.form
          wf
        }
      }
    end

  end

  # GET /workflows/1
  # GET /workflows/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: Workflow.find(params[:id]).export }
    end
  end

  def new_operation
    workflow = Workflow.find(params[:id])
    op = workflow.new_operation # creates new op, adds it to workflow, returns the op
    render json: op
  end

  def drop_operation
    workflow = Workflow.find(params[:id])
    op = Operation.find(params[:oid])
    workflow.drop_operation op
    render json: workflow.export
  end  

  def identify
    workflow = Workflow.find(params[:id])
    workflow.identify params[:source].to_i, params[:dest].to_i, params[:output], params[:input]
    render json: workflow.export   
  end

  # GET /workflows/new
  # GET /workflows/new.json
  def new
    @workflow = Workflow.new
    @workflow.name = "New workflow"
    @workflow.specification = ({
        operations: [],
        io: [],
        description: "A new workflow that has not yet been carefully described."
      }).to_json
    @workflow.save
    redirect_to @workflow

  end

  # GET /workflows/1/edit
  def edit
    @workflow = Workflow.find(params[:id])
  end

  # POST /workflows
  # POST /workflows.json
  def create
    @workflow = Workflow.new(params[:workflow])

    respond_to do |format|
      if @workflow.save
        format.html { redirect_to @workflow, notice: 'Workflow was successfully created.' }
        format.json { render json: @workflow, status: :created, location: @workflow }
      else
        format.html { render action: "new" }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workflows/1
  # PUT /workflows/1.json
  def update
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      if @workflow.update_attributes(params[:workflow])
        format.html { redirect_to @workflow, notice: 'Workflow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  def nils_to_empty_arrays obj

    # fixes an issue where rails turns [] into nil in json data passed to params

    case obj
      when nil
        return []
      when Array
        return obj.collect { |x| nils_to_empty_arrays x }
      when Hash
        newobj = {}
        obj.each do |k,v|
          newobj[k.to_sym] = nils_to_empty_arrays v
        end
        return newobj
      else
        return obj
    end

  end

  def save

    # Save operations

    fixed_params = (nils_to_empty_arrays params)

    logger.info "new params = #{fixed_params}"

    fixed_params[:specification][:operations].each do |h|

      logger.info "h = #{h.inspect}"

      o = Operation.find(h[:id])
      o.name = h[:operation][:name]
      o.protocol_path = h[:operation][:protocol]
      o.specification = h[:operation].to_json
      o.save

    end

    # Save workflow

    w = Workflow.find(fixed_params[:id])

    w.name = fixed_params[:name]

    w.specification = ({ 
      operations: fixed_params[:specification][:operations].collect { |o| { 
          id: o[:id].to_i, x: o[:x], y: o[:y], timing: o[:timing]
        }
      },
      io: fixed_params[:specification][:io],
      description: fixed_params[:specification][:description]
    }).to_json

    w.save

    render json: { result: "okay" }

  end

  # DELETE /workflows/1
  # DELETE /workflows/1.json
  def destroy
    @workflow = Workflow.find(params[:id])
    FolderContent.where(workflow_id: @workflow.id).destroy_all
    @workflow.destroy

    respond_to do |format|
      format.html { redirect_to workflows_url }
      format.json { head :no_content }
    end
  end
  
end
