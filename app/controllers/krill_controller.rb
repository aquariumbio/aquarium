class KrillController < ApplicationController

  before_filter :signed_in_user

  def arguments 

    @path = params[:path]
    @sha = Repo::version @path

  end

  def submit

    begin
      @arguments = JSON.parse params[:args], symbolize_names: true
    rescue Exception => e
      flash[:error] = "Error parsing arguments: " + e.to_s
      return redirect_to krill_arguments_path(path: params[:path], sha: params[:sha], args: params[:args])
    end

    @job = Job.new
    @job.path = params[:path]
    @job.sha = params[:sha]

    @job.user_id = -1
    @job.pc = Job.NOT_STARTED
    @job.state = [{operation: "initialize", arguments: @arguments}].to_json

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
        server_result = ( Krill::Client.new.start params[:job] )
      rescue Exception => e
        return redirect_to krill_error_path(job: @job.id, message: e.to_s)
      end

    end

    if server_result[:error]
      return redirect_to krill_error_path(job: @job.id, message: server_result[:error])
    end

    # redirect to interpreter
    redirect_to krill_interpreter_path(job: params[:job]) 

  end

  def error

    @message = params[:message]
    @job = Job.find(params[:job])

  end
  
  def continue

    @job = Job.find(params[:job])

    if @job.pc >= 0

      state = JSON.parse @job.state, symbolize_names: true

      state.push( { operation: "next", time: Time.now } )
      @job.state = state.to_json
      @job.save

      # Tell Krill server to take the next step in the protocol 
      begin
        server_result = ( Krill::Client.new.continue params[:job] )
      rescue Exception => e
        flash[:notice] = e.to_s
      end

      if server_result[:error]
        return redirect_to krill_error_path(job: @job.id, message: server_result[:error])
      end

      # redirect to interpreter
      redirect_to krill_interpreter_path(job: params[:job]) 

    elsif @job.pc == Job.NOT_STARTED
      redirect_to krill_error_path(job: @job.id, message: "continue: Job not started") 
    else
      redirect_to krill_completed_path(job: params[:job]) 
    end

  end

  def completed

    @job = Job.find(params[:job])

  end

  def interpreter

    @job = Job.find(params[:job])

    if @job.pc >= 0

      @job = Job.find(params[:job])
 
    elsif @job.pc == Job.NOT_STARTED
      redirect_to krill_error_path(job: @job.id, message: "interpreter: Job not started") 
    else
      redirect_to krill_completed_path(job: params[:job]) 
    end

  end

end
