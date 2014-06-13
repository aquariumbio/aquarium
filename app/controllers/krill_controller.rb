class KrillController < ApplicationController

  before_filter :signed_in_user

  def arguments 

  end

  def submit

    @job = Job.new
    @job.path = "temp.kl"
    @job.sha = "12323456789"

    @job.user_id = -1
    @job.pc = Job.NOT_STARTED
    @job.state = [].to_json

    @job.group_id = 1
    @job.submitted_by = current_user.id
    @job.desired_start_time = Time.now
    @job.latest_start_time = Time.now + 1.hour

    @job.save

  end

  def start

    @job = Job.find(params[:job])

    # if not running, then start
    if @job.pc == Job.NOT_STARTED
 
      # Tell Krill server to start protocol 
      begin
        flash[:notice] = "START: " + ( Krill::Client.new.start params[:job] ).to_s
      rescue Exception => e
        flash[:notice] = e
      end

    end

    # redirect to interpreter
    redirect_to krill_interpreter_path(job: params[:job]) 

  end
  
  def continue

    # Tell Krill server to take the next step in the protocol 
    begin
      flash[:notice] = "CONTINUE: " + ( Krill::Client.new.continue params[:job] ).to_s
    rescue Exception => e
      # flash[:notice] = e.to_s
    end

    # redirect to interpreter
    redirect_to krill_interpreter_path(job: params[:job]) 

  end

  def interpreter

    @job = Job.find(params[:job])

  end

end
