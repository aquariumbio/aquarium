class WorkflowProcessesController < ApplicationController

  def index
    @workflow_processes = WorkflowProcess.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflow_processes }
    end    
  end

  def show
    @workflow_process = WorkflowProcess.find(params[:id])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflow_process }
    end      
  end

  def new
    @workflow = Workflow.find(params[:wid])
  end

end