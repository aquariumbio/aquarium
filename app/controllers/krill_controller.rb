class KrillController < ApplicationController

  before_filter :signed_in_user

  def arguments 

    begin
      @path = params[:path] 
      if params[:sha]
        @sha = params[:sha]
      else
        @sha = Repo::version @path
      end
      @content = Repo::contents @path, @sha
    rescue Exception => e
      flash[:error] = e.to_s + ". " + e.backtrace[0].to_s
      return redirect_to repo_list_path
    end

    if params[:from]

      begin
        @args = JSON.parse(Job.find(params[:from].to_i).state,symbolize_names:true).last[:rval]
        argval = JSON.parse(Job.find(params[:from].to_i).state,symbolize_names:true).last[:rval]
      rescue Exception => e
        flash[:error] = "Could not parse arguments from job #{params[:from]}" + e.to_s
        return redirect_to repo_list_path
      end

      #return redirect_to krill_submit_path(path: @path, sha: @sha, args: argval.to_json)

    else  

      begin
        @args = Krill::get_arguments @content
      rescue Exception => e
        flash[:error] = ("<b>Could not parse '#{@path}'</b><br />" + e.to_s.gsub(/\n/,'<br />').gsub(/\(eval\):/,'line ')).html_safe
        return redirect_to repo_list_path
      end

    end

  end

  def submit

    # Parse arguments
    begin
      @arguments = JSON.parse params[:args], symbolize_names: true
    rescue Exception => e
      flash[:error] = "Error parsing arguments: " + e.to_s
      return redirect_to krill_arguments_path(path: params[:path], sha: params[:sha], args: params[:args])
    end

    # Determine group and timing info
    @info = JSON.parse(params[:info],:symbolize_names => true)
    @desired = Time.at(@info[:date])
    @window = @info[:window].to_f
    @latest = Time.at(@desired + @window.hours)
    @group = Group.find_by_name(@info[:group])

    # Make a new job
    @job = Job.new
    @job.path = params[:path]
    @job.sha = params[:sha]

    # Set up job parameters
    @job.pc = Job.NOT_STARTED
    @job.set_arguments @arguments
    @job.group_id = @group.id
    @job.submitted_by = current_user.id
    @job.desired_start_time = @desired
    @job.latest_start_time = @latest

    # Save the job
    @job.save

  end

  def start

    @job = Job.find(params[:job])

    # if not running, then start
    if @job.pc == Job.NOT_STARTED

      @job.user_id = current_user.id
      @job.save
 
      # Tell Krill server to start protocol 
      begin
        server_result = ( Krill::Client.new.start params[:job] )
      rescue Exception => e
        return redirect_to krill_error_path(job: @job.id, message: e.to_s, backtrace: e.backtrace[0,2])
      end

      if !server_result
        return redirect_to krill_error_path(job: @job.id, message: "Krill server returned nil, which is a bad sign.", backtrace: [])
      elsif server_result[:error]
        return redirect_to krill_error_path(
          job: @job.id, 
          message: ("server error: " + server_result[:error][0,512]).html_safe,
          backtrace: [])
      end

    end

    # redirect to ui
    redirect_to krill_ui_path(job: params[:job]) 

  end

  def debug

    errors = []
    @job = Job.find(params[:id])

    # if not running, then start
    if @job.pc == Job.NOT_STARTED

      @job.user_id = current_user.id
      @job.save

      begin
        manager = Krill::Manager.new @job.id, true, "master", "master"
      rescue Exception => e
        error = e
      end

      if error
        errors << error
      else

        begin
          manager.run
        rescue Exception => e        
          errors << e.message
        end

      end
 
    end

    Operation.step

    render json: { errors: errors, operations: @job.reload.operations, job: @job }

  end

  def error

    @message = params[:message]
    @backtrace = params[:backtrace]|| []
    @job = Job.find(params[:job])

  end

  def state

    @job = Job.find(params[:job])
    render json: { state: (JSON.parse @job.state), result: { response: "n/a" } }

  end

  def abort

    begin
      result = Krill::Client.new.abort params[:job]
    rescue Exception => e
      result = { response: "error", message: e.to_s }
    else

      @job = Job.find(params[:job])
      @job.stop "error"
      @job.operations.each do |op|
        op.associate :aborted, "Operation was canceled when job #{@job.id} was aborted"
      end

      state = JSON.parse @job.state, symbolize_names: true
      if state.length % 2 == 1 # backtrace ends with a 'next'
        @job.append_step operation: "display", content: [ 
          { title: "Interrupted" },
          { note: "This step was being prepared by the protocol when the 'abort' signal was received."} ]
      end

      # add next and final
      @job.append_step operation: "next", time: Time.now, inputs: {}
      @job.append_step operation: "aborted", rval: {}

      logger.info "ABORTING KRILL JOB #{@job.id}"

    end

    render json: result

  end

  def jobs

    begin
      result = Krill::Client.new.jobs
    rescue Exception => e
      result = { response: "error", message: e.to_s }
    end

    render json: result

  end

  def next

    @job = Job.find(params[:job])

    if @job.pc >= 0

      state = JSON.parse @job.state, symbolize_names: true

      unless state.last[:operation] == "next" || params[:command] == "check_again"
        state.push( { 
          operation: params[:command], 
          time: Time.now, inputs: 
          JSON.parse(params[:inputs], symbolize_names: true)
        } )
        @job.state = state.to_json
        @job.save
      end

      # Tell Krill server to take continue in the protocol 
      begin
        result = ( Krill::Client.new.continue params[:job] )
      rescue Exception => e
        result = { response: "error", error: "Call to server raised #{e.to_s}" }
      end

      if !result
        result = { response: "error", error: "Server returned nil, a bad sign." }
      end

      if result[:response] == "done"

        # step the job's workflow (remove once workflows are removed)
        @job.reload.step_workflow

        Thread.new do # this goes in the background because it can take a 
                      # while, and the technician interface should not have
                      # to wait
          Operation.step
        end        

      else

        @job.reload

      end

    else 

      result = { response: "error", error: "Job is no longer running." }

    end

    render json: ( { state: (JSON.parse @job.state), result: result } )

  end

  def log

    begin
      @job = Job.includes(:user,:group,:touches,:uploads,:takes).find(params[:job])
    rescue
      redirect_to logs_path
      return
    end

    @group = @job.group
    @submitter = User.find(@job.submitted_by)
    @performer = @job.user

    @history = @job.state
    @rval = @job.return_value
    @touches = (@job.touches.select { |t| t.item_id }).collect { |t| t.item_id }
    @tasks = ( ( @job.touches.select { |t| t.task } ).collect { |t| t.task } ).uniq { |task| task.id }
    @inventory = @job.takes.collect { |t| t.item_id }

    render layout: 'aq2'

  end

  def ui

    @job = Job.find(params[:job])

    if @job.pc == Job.NOT_STARTED
      redirect_to krill_error_path(job: @job.id, message: "interpreter: Job not started") 
      return
    end

    render layout: 'aq2-plain'

  end

  def inventory

    job = Job.find(params[:job])

    takes = job.takes.includes(item: [ :object_type, :sample ] ).collect {
      |t| t.item.all_attributes 
    }

    touches = (job.touches.includes(item: [ :object_type, :sample ] ).reject { 
      |t| !t.item_id || (takes.collect { |i| i[:id] }).include?( t.item_id )
    }).collect { 
      |t| t.item.all_attributes
    }

    render json: { takes: takes, touches: touches }

  end

  def upload

    logger.info "upload = #{params[:files][0]}"

    u = Upload.new

    File.open(params[:files][0].tempfile) do |f|
      u.upload = f # just assign the logo attribute to a file
      u.name = params[:files][0].original_filename
      u.job_id = params[:job]
      u.save
    end

    unless u.errors.empty?
      logger.info "ERRORS: #{u.errors.full_messages}"
      render json: { error: "#{u.errors.full_messages}" }
      return
    end

    render json: { upload_id: u.id, name: u.name }

  end

  def uploads

    render json: { uploads: Job.find(params[:job]).uploads.collect { |u| { id: u.id, name: u.name, url: u.url } } }

  end

  def tasks

    job = Job.find(params[:job])
    render json: { tasks: ((job.touches.includes(task: [ :task_prototype ] ).select { |t| t.task_id }).collect { |t| { id: t.task.id, name: t.task.name, type: t.task.task_prototype.name } }).uniq }

  end

end

