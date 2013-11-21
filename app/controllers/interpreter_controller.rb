require 'socket'

class InterpreterController < ApplicationController

  def get_blob 

    # Gets a blob from the db and parses the xml to check for errors.
    # When parse_xml is called, the resulting xml is associated with the
    # protocol, so that it can later be parsed into a program

    blob = Blob.get @sha, params[:path]

    @file = blob.xml
    @path = blob.path

    if /\.pl$/.match @path # it's a plankton file ##########################

      logger.info "Opening a plankton file!"

      @protocol = Plankton::Parser.new( @path, @file )

      logger.info "And " + @protocol.class.to_s

      @parse_errors = ""

      if params[:job]
        @protocol.job_id = params[:job].to_i
      else
        @protocol.job_id = -1
      end

    else # it's a pdl file ##################################################

      logger.info "Opening a boring old xml file named #{@path}"

      @protocol = Protocol.new
      if params[:job]
        @protocol.job_id = params[:job].to_i
      else
        @protocol.job_id = -1
      end

      @parse_errors = ""

      begin
        @protocol.parse_xml @file
      rescue Exception => e
        @parse_errors = e.message
      end

    end    

  end

  def parse

    # Creates a protocol via get_blob, which uses params[:path] to determine which file to use, 
    # and then parses the file to get a @protocol.progrom, which has a list of instructions.

    get_blob

    begin
      @protocol.parse
    rescue Exception => e
      @parse_errors = "Error while parsing. " + e.message #  + ": " + e.backtrace.to_s
    end

  end

  def parse_args_only

    # Parses only the arguments of a protocol (to avoid descending into included files) so 
    # that the protocol object can be used to display arguments to the user.

    get_blob

    if @parse_errors == ""

      begin
        @protocol.parse_arguments_only
      rescue Exception => e
        @parse_errors = "Error while parsing arguments. " + e.message # + ": " + e.backtrace.to_s
      end

    end

  end

  def arguments

    # Shows the argument dialog to the user

    @sha = params[:sha]
    @path = params[:path]
    @user = current_user
    parse_args_only

    respond_to do |format|
      format.html
    end

  end

  def open_local_file

    # Opens a local file specified in params. Each local file opening, whether the file
    # has changes or not, creates a new Blob. Once the blob is made, it is parsed and the
    # arguments dialog is shown.

    @path = params[:protocol_file].original_filename;
    @sha = 'local_file_' + session[:session_id].to_s + '_' + Time.now.to_i.to_s;

    logger.info 'local file: ' + @sha;

    blob = Blob.new
    blob.path = @path
    blob.sha = @sha
    blob.xml = params[:protocol_file].read
    blob.save

    parse # why is this not parse_args_only?

    render 'arguments' 

  end

  def submit

    # Submits the job

    @sha = params[:sha]
    @path = params[:path]
    @desired = Job.params_to_time(params[:Desired])
    @window = params[:window].to_f
    @latest = @desired + @window.hours
    @group = Group.find_by_name(params[:Group])

    parse_args_only

    scope = Lang::Scope.new {}

    # push arguments
    @protocol.args.each do |a|
      val = params[a.name.to_sym]
      if a.type == 'number' && val.to_i == val.to_f
        scope.set a.name.to_sym, val.to_i
      elsif a.type == 'number' && val.to_i != val.to_f
        scope.set a.name.to_sym, val.to_f
      else
        scope.set a.name.to_sym, val
      end
    end

    # push new scope so top level variables are not in same scope as arguments
    scope.push

    @job = Job.new
    @job.sha = @sha
    @job.path = @path
    @job.user_id = -1
    @job.pc = Job.NOT_STARTED
    @job.state = { stack: scope.stack }.to_json

    @job.group_id = @group.id
    @job.submitted_by = current_user.id
    @job.desired_start_time = @desired
    @job.latest_start_time = @latest

    @job.save

    respond_to do |format|
      format.html
    end

  end

  def get_current
 
    # Get the job

    begin
      @job = Job.find(params[:job])
    rescue Exception => e
      process_error "Job #{params[:job]} is no longer active"
      return
    end

    state = JSON.parse(@job.state, {:symbolize_names => true} )

    # Get the protocol
    @sha = @job.sha
    @path = @job.path

    parse
    if @parse_errors != ""
      log 'ERROR', { error: @parse_errors, pc: @job.pc }
      @pc = Job.COMPLETED
    else
      # Get the pc and scope
      @pc = @job.pc
      @scope = Lang::Scope.new
      @scope.set_stack state[:stack]
      @scope.set_base_symbol :user_id, current_user.id
      @instruction = @protocol.program[@pc]
    end

  end

  def process_error msg

    @exception = true
    @error = msg
    @error_pc = @pc
    log "ERROR", { pc: @pc, message: msg, instruction: @instruction.name }
    stop
    @job.pc = @pc
    @job.state = { stack: @scope.stack }.to_json
    @job.save

  end

  def pre_render

    # Calls pre-render for the current instruction

    begin
      @instruction.pre_render @scope, params if @instruction.respond_to?('pre_render')
      if @instruction.flash != "" 
        flash[:alert] = @instruction.flash.html_safe
      end
    rescue Exception => e
      process_error "Error in pre_render of " + @instruction.name + ": " + e.to_s # + ", " + e.backtrace.to_s
    end  

  end

  def current

    get_current
    unless @pc == Job.COMPLETED
      pre_render
    end
    render 'current'

  end

  def execute

    if @instruction.respond_to?('bt_execute')
      @instruction.bt_execute @scope, params
      if @instruction.flash != "" 
        flash[:alert] = @instruction.flash.html_safe
      end
    end

    if @instruction.respond_to?("set_pc")
      @pc = @instruction.set_pc @scope
    else
      @pc += 1
    end

  end

  def log type, data
    log = Log.new
    log.job_id = @job.id
    log.user_id = current_user.id
    log.entry_type = type
    log.data = data.to_json
    log.save
  end

  def start

    # initialize
    log "START", {}
    @pc = 0
    @job.user_id = current_user.id

    # tell manta we're starting a protocol
    Thread.new do
      @manta = "http://istc.cs.washington.edu:8800/start?&job=#{@job.id}&server=" + Socket.gethostname + ":" + request.port.to_s + "&user=" + current_user.login + "&protocol=#{@path}"
      uri= URI(@manta)
      res = Net::HTTP.get(uri)
      logger.info "Message to MANTA: " + uri.to_s
      logger.info "Message from MANTA: " + res
    end

    if @parse_errors != ""
      stop
    end

  end

  def stop
  
    # finalize stuff
    @pc = Job.COMPLETED
    log "STOP", {}

    # tell manta we're done
    Thread.new do
      uri = URI("http://istc.cs.washington.edu:8800/stop?&job=#{@job.id}&server=" + Socket.gethostname + ":" + request.port.to_s + "&abort=" + ( @exception ? 'true' : 'false' ))
      res = Net::HTTP.get(uri)
      logger.info "Message from MANTA: " + res
    end

  end

  def advance

    get_current

    if @pc != Job.COMPLETED

      if @pc >= 0
        log "NEXT", { pc: @pc, instruction: @instruction.name }
        if params[:lognote]
          log "NOTE", { pc: @pc, content: params[:lognote] }
        end
        begin
          execute
        rescue Exception => e
          process_error "Error executing #{@instruction.name}: " + e.to_s # + ', ' + e.backtrace.to_s
          render 'current'
          return
        end
      else
        start
      end

      # continue through instructions that are not renderable
      if @pc < @protocol.program.length

        @instruction = @protocol.program[@pc]

        while !@instruction.renderable && @pc < @protocol.program.length
          begin
            execute
          rescue Exception => e
            process_error "Error executing #{@instruction.name}: " + e.to_s # + ', ' + e.backtrace.to_s
            render 'current'
            return
          end
          @instruction = @protocol.program[@pc] if @pc < @protocol.program.length
        end

      end

      # check if protocol is finished
      if @pc < @protocol.program.length
        @instruction = @protocol.program[@pc]
      else
        stop
      end

      @job.pc = @pc
      @job.state = { stack: @scope.stack }.to_json
      @job.save

      pre_render
  
    end

    render 'current'

  end

  def abort
   @job = Job.find(params[:job])
   if @job.pc != Job.COMPLETED
     @job.pc = Job.COMPLETED
     @job.save
     @pc = Job.COMPLETED
     log "ABORT", {}
   end
   render 'abort'
  end

  def cancel
   @job = Job.find(params[:job])
   if @job.pc != Job.COMPLETED
     @job.pc = Job.COMPLETED
     @job.save
     @pc = Job.COMPLETED
     log "CANCEL", {}
   end
   flash[:success] = "Job #{params[:job]} has been cancelled."
   redirect_to jobs_url
  end

end
