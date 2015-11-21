class WorkflowProcessesController < ApplicationController

  before_filter :signed_in_user

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: WorkflowProcess.all }        
    end
  end

  def active
    render json: Job.includes(workflow_process: :jobs)
      .where("pc >= -1 AND workflow_process_id is not null")
      .collect { |j| 
        wp = j.workflow_process
        wpj = wp.as_json(include: :jobs)
        wpj[:state] = wp.state_hash
        wpj
      }
      .uniq
  end

  def recent

    a = Time.now - params[:days_ago].to_i.days
    b = Time.now - params[:days_ago].to_i.days + 1.days

    recently_updated = WorkflowProcess
      .includes(:jobs)
      .where("? < updated_at AND updated_at <= ?", a, b )
      .reject { |wp| wp.active? }
      .collect { |wp| 
        wpj = wp.as_json(include: :jobs)
        wpj[:state] = wp.state_hash
        wpj
      }

    recently_updated_via_jobs = Job.includes(workflow_process: :jobs)
      .where("? < updated_at AND updated_at <= ? AND workflow_process_id is not null", a, b)
      .collect { |j| 
        j.workflow_process
      }
      .reject { |wp| wp.active? }
      .collect { |wp| 
        wpj = wp.as_json(include: :jobs)
        wpj[:state] = wp.state_hash
        wpj
      }

      render json: (recently_updated+recently_updated_via_jobs).uniq

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

    @wp = WorkflowProcess.find(params[:id])
    @wp.step
    redirect_to workflow_process_url(@wp)

  end

  def kill 
    wp = WorkflowProcess.includes(:jobs).find(params[:id])
    wp.jobs.each do |j|
      j.cancel current_user
    end
    wp.reload
    wpj = wp.as_json(include: :jobs)
    wpj[:state] = wp.state_hash
    wpj
    render json: { status: "killed process #{params[:id]}", process: wpj }
  end

end