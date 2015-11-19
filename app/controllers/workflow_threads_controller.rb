class WorkflowThreadsController < ApplicationController

  before_filter :signed_in_user

  def index

    if params[:workflow_id]
     render json: WorkflowThread.where(workflow_id: params[:workflow_id].to_i,process_id: nil)
    else
      render json: WorkflowThread.all
    end

  end

  def create

    wf = Workflow.find(params[:workflow_id])
    spec = wf.make_spec_from_hash(params[:thread])

    begin

      thread = WorkflowThread.create(spec,params[:workflow_id],current_user)      

      render json: { 
          id: thread.id,
          user: current_user,
          workflow: {
            id: thread.workflow.id,
            name: thread.workflow.name
          },
          role: "unknown",
          process_id: nil,
          specification: thread.specification,
          updated_at: thread.updated_at,
          created_at: thread.created_at
        } 

    rescue Exception => e
    
      render json: { error: e.to_s, backtrace: e.backtrace.join('\n') }

    end

  end

  def destroy

    @thread = WorkflowThread.find(params[:id])
    @thread.destroy

    render json: { results: "ok" }

  end  

end