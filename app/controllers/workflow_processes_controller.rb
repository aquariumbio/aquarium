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

    if params[:debug].class == String
      debug = ( params[:debug] == "true" ? true : false )
    else
      debug = params[:debug]
    end

    @wp = WorkflowProcess.create @workflow, @threads, debug

    Thread.new do
      @wp.launch
    end

    render json: @wp

  end

  def rerun

    Rails.logger.info "Rerunning process #{params[:id]}"

    @wp = WorkflowProcess.find(params[:id])
    @workflow = @wp.workflow

    @threads = @wp.threads.collect { |t|
      WorkflowThread.create t.spec, t.workflow_id
    }

    if params[:debug].class == String
      debug = ( params[:debug] == "true" ? true : false )
    else
      debug = params[:debug]
    end

    @workflow_process = WorkflowProcess.create @workflow, @threads, debug

    Thread.new do
      @workflow_process.launch
    end

    redirect_to workflow_process_url(@workflow_process)

  end

  def debug

    @wp.launch

    i = 0 # avoid infinite loops during development

    while !@wp.completed? && i < 20

      # run all jobs associated with the workflow
      (@wp.jobs.select { |job| job.not_started? }).each do |job|
        result = Krill::Client.new.start job.id
        if result[:response] == "error"
          raise "Krill could not start #{job.id}: #{result[:error]}"
        end
        job.reload
        if job.error?
          raise "Job #{job.id} failed"
        end
        @wp.record_result_of job

      end

      @wp.step
      @wp.reload

      i += 1

    end    

  end

  def step

    WorkflowProcess.find(params[:id]).step
    redirect_to workflow_process_url(@wp)

  end

end