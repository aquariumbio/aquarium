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

    thread = WorkflowThread.create(
      spec,
      params[:workflow_id]
    )

    Rails.logger.info "CREATE THREAD: created #{thread.id} with spec #{thread.spec}, made from #{params[:thread]}"

    render json: thread

  end

  def destroy

    @thread = WorkflowThread.find(params[:id])
    @thread.destroy

    render json: { results: "ok" }

  end  

end