class WorkflowProcessesController < ApplicationController

  before_filter :signed_in_user

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

  def create

    @workflow = Workflow.find(params[:workflow_id])
    @threads = params[:thread_ids].collect { |tid| WorkflowThread.find(tid) }
    @wp = WorkflowProcess.create @workflow, @threads, params[:debug]

    Thread.new do
      @wp.launch
    end

    render json: @wp

  end

  def debug

    logger.info "WORKFLOW DEBUGGER: starting process #{@wp.id}"

    @wp.launch

    i = 0 # avoid infinite loops during development

    while !@wp.completed? && i < 20

      # run all jobs associated with the workflow
      (@wp.jobs.select { |job| job.not_started? }).each do |job|
        result = Krill::Client.new.start job.id
        logger.info "WORKFLOW DEBUGGER: Job #{job.id} started for process #{@wp.id}."        
        if result[:response] == "error"
          raise "Krill could not start #{job.id}: #{result[:error]}"
        end
        job.reload
        if job.error?
          logger.info "WORKFLOW DEBUGGER: Job #{job.id} failed for process #{@wp.id}, aborting debug."
          raise "Job #{job.id} failed"
        end
        @wp.record_result_of job

      end

      @wp.step
      @wp.reload

      i += 1

    end    

    logger.info "WORKFLOW DEBUGGER: process #{@wp.id} completed."    

  end

end