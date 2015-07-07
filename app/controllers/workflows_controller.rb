class WorkflowsController < ApplicationController
  # GET /workflows
  # GET /workflows.json
  def index
    @workflows = Workflow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflows }
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
    @workflow.specification = ({
        operations: [],
        io: [],
        description: ""
      }).to_json

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workflow }
    end
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

  def save

    logger.info params[:id]
    logger.info params[:name]
    logger.info params[:specification][:operations].collect { |o| { 
        id: o[:id].to_i, x: o[:x], y: o[:y]
      }
    }
    logger.info params[:specification][:io]
    logger.info params[:specification][:description]    

    w = Workflow.find(params[:id])

    w.name = params[:name]

    w.specification = ({ 
      operations: params[:specification][:operations].collect { |o| { 
          id: o[:id].to_i, x: o[:x], y: o[:y]
        }
      },
      io: params[:specification][:io],
      description: params[:specification][:description]
    }).to_json

    w.save

    if w.errors 
      render json: { result: "error" }
    else
      render json: { result: "okay" }
    end

  end

  # DELETE /workflows/1
  # DELETE /workflows/1.json
  def destroy
    @workflow = Workflow.find(params[:id])
    @workflow.destroy

    respond_to do |format|
      format.html { redirect_to workflows_url }
      format.json { head :no_content }
    end
  end
end
