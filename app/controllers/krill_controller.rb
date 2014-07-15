class KrillController < ApplicationController

  before_filter :signed_in_user

  def arguments 

    begin
      @path = params[:path]
      @sha = Repo::version @path
      @content = Repo::contents @path, @sha
    rescue Exception => e
      flash[:error] = e.to_s + ". " + e.backtrace[0].to_s
      return redirect_to repo_list_path
    end

    begin
      @args = Krill::get_arguments @content
    rescue Exception => e
      flash[:error] = ("<b>Could not parse '#{@path}'</b><br />" + e.to_s.gsub(/\n/,'<br />').gsub(/\(eval\):/,'line ')).html_safe
      return redirect_to repo_list_path
    end

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

    @job.user_id = current_user.id;
    @job.pc = Job.NOT_STARTED
    @job.state = [{operation: "initialize", arguments: @arguments, time: Time.now}].to_json

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
        return redirect_to krill_error_path(job: @job.id, message: e.to_s + ": " + e.backtrace[0,5].to_s)
      end

    end

    if server_result[:error]
      return redirect_to krill_error_path(job: @job.id, message: server_result[:error])
    end

    # redirect to ui
    redirect_to krill_ui_path(job: params[:job]) 

  end

  def error

    @message = params[:message]
    @job = Job.find(params[:job])

  end

  def state

    @job = Job.find(params[:job])
    render json: (JSON.parse @job.state)

  end

  def next

    @job = Job.find(params[:job])

    if @job.pc >= 0

      state = JSON.parse @job.state, symbolize_names: true

      state.push( { operation: "next", time: Time.now, inputs: params[:inputs] } )
      @job.state = state.to_json
      @job.save
      updated = @job.updated_at

      # Tell Krill server to take the next step in the protocol 
      begin
        server_result = ( Krill::Client.new.continue params[:job] )
      rescue Exception => e
        flash[:notice] = e.to_s
      end

      if server_result[:error]
        return redirect_to krill_error_path(job: @job.id, message: server_result[:error])
      end

      @job.reload

      if updated == @job.updated_at
        flash[:notice] = "Warning: job state not updated in Krill:next"
      end

    end

    render json: (JSON.parse @job.state)

  end

  def log

    @job = Job.find(params[:job])
    @history = @job.state
    @inventory = @job.takes.collect { |t| t.id }

  end

  def ui

    @job = Job.find(params[:job])

    if (JSON.parse @job.state).length % 2 != 0
      flash[:error] = "Warning: job state may not have been completely updated yet. Try reloading."
    end

    if @job.pc == Job.NOT_STARTED
      redirect_to krill_error_path(job: @job.id, message: "interpreter: Job not started") 
    end


  end

  def inventory

    job = Job.find(params[:job])

    takes = job.takes.includes(item: [ :object_type, :sample ] ).collect {
      |t| t.item.all_attributes 
    }

    touches = (job.touches.includes(item: [ :object_type, :sample ] ).reject { 
      |t| (takes.collect { |i| i[:id] }).include?( t.item_id )
    }).collect { 
      |t| t.item.all_attributes
    }

    render json: { takes: takes, touches: touches }

  end

end

