require 'socket'

class InterpreterController < ApplicationController

  before_filter :signed_in_user

  def get_protocol path, sha

    @path = path
    @sha = sha

    if /local_file/ =~ @sha
      blob = Blob.get @sha, @path
      @content = blob.xml.force_encoding('UTF-8')
    else
      @content = Repo::contents @path, @sha
    end

    @protocol = Plankton::Parser.new( @path, @content )

    logger.info "HERE, PROTOCOL = #{@protocol}"

    @parse_errors = ""

    if params[:job]
      @protocol.job_id = params[:job].to_i
    else
      @protocol.job_id = -1
    end

  end

  def get_blob 

    # Gets a blob from the db and parses the code to check for errors.
    # When parse_xml is called, the resulting code is associated with the
    # protocol, so that it can later be parsed into a program

    blob = Blob.get @sha, params[:path]

    @file = blob.xml.force_encoding('UTF-8')
    @path = blob.path

    if /\.pl/.match @path # it's a plankton file ##########################

      logger.info "Opening a plankton file: #{@path}!"
      @protocol = Plankton::Parser.new( @path, @file )
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

    get_protocol @job.path, @job.sha

    begin
      @protocol.parse
    rescue Exception => e
      @parse_errors = "Error while parsing. " + e.message + ": " + e.backtrace.to_s
    end

  end

  def parse_args_only

    # Parses only the arguments of a protocol (to avoid descending into included files) so 
    # that the protocol object can be used to display arguments to the user.

    get_protocol params[:path], params[:sha]

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
    # has changed or not, creates a new Blob. Once the blob is made, it is parsed and the
    # arguments dialog is shown.

    @path = params[:protocol_file].original_filename;
    @sha = 'local_file_' + session[:session_id].to_s + '_' + Time.now.to_i.to_s;

    blob = Blob.new
    blob.path = @path
    blob.sha = @sha
    blob.xml = params[:protocol_file].read
    blob.save

    if /\.oy$/.match @path # its a metacol

      redirect_to arguments_new_metacol_path(sha: @sha, path: @path) 

    else # its a protocol

      #parse # why is this not parse_args_only? or even just dropped since rendering arguments does a parse_args_only
      redirect_to interpreter_arguments_path( path: @path, sha: @sha )

    end

  end

  def edit

    @job = Job.find(params[:job])
    @sha = @job.sha
    @path = @job.path
    @user = current_user

    @current_args = JSON.parse(@job.state, {:symbolize_names => true} )[:stack][0]

    parse_args_only

    respond_to do |format|
      format.html
    end

  end

  def submit

    # Submits the job

    @sha = params[:sha]
    @path = params[:path]

    @info = JSON.parse(params[:info],:symbolize_names => true)

    @desired = Time.at(@info[:date])
    @window = @info[:window].to_f
    @latest = Time.at(@desired + @window.hours)
    @group = Group.find_by_name(@info[:group])

    parse_args_only

    scope = Lang::Scope.new {}

    # push arguments
    @protocol.args.each do |a|
      val = @info[:args][a.name.to_sym]
      if a.type == 'number' && val.to_i == val.to_f
        scope.set a.name.to_sym, val.to_i
      elsif a.type == 'number' && val.to_i != val.to_f
        scope.set a.name.to_sym, val.to_f
      elsif a.type == 'generic'
        begin
          if val.class == String # arg was entered in by user
            scope.set a.name.to_sym, JSON.parse(val,:symbolize_names => true)
          else # arg was obtained from previous job's args
            scope.set a.name.to_sym, val.symbolize_keys
          end
        rescue Exception => e
          flash[:error] = "Error parsing json for generic argument #{a.name}: " + e.to_s
          return redirect_to interpreter_arguments_path(sha: @sha, path: @path) 
        end
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

    $CURRENT_JOB_ID = @job.id

    state = JSON.parse(@job.state, {:symbolize_names => true} )

    # Get the protocol
    @sha = @job.sha
    @path = @job.path
    @pc = @job.pc

    if @pc != Job.COMPLETED

      parse
 
      if @parse_errors != ""
        log 'ERROR', { error: @parse_errors, pc: @job.pc }
        @pc = Job.COMPLETED
        @job.pc = Job.COMPLETED
        @job.save
      else
        # Get the pc and scope
        @scope = Lang::Scope.new
        @scope.set_stack state[:stack]
        @scope.set_base_symbol :user_id, current_user.id
        @instruction = @protocol.program[@pc]
      end

    else

      @parse_errors = ""

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
    log "START", { location: cookies[:location] ? cookies[:location] : 'undefined' }
    @pc = 0
    @job.user_id = current_user.id

    # tell manta we're starting a protocol
    Thread.new do

      logger.info "Starting thread to talk to MANTA #{Socket.gethostname}:#{request.port.to_s}"

      begin
        manta = URI::escape "http://istc.cs.washington.edu:8800/start?&job=#{@job.id}&server=" + Socket.gethostname + ":" + request.port.to_s + "&user=" + (current_user.login) + "&protocol=#{@path}"  + "&location=" + ( cookies[:location] ? cookies[:location] : 'undefined' )
      rescue Exception => e
        logger.info "Error on setting up URI: " + e.to_s
      end

      logger.info "uri = #{manta}"
      
      begin
        uri= URI(manta)
        res = Net::HTTP.get(uri)
        logger.info "Message to MANTA on start: " + uri.to_s
        logger.info "Message from MANTA on start: " + res
      rescue Exception => e
        logger.info "Could not talk to MANTA on start: " + e.to_s
      end

    end

    if @parse_errors != ""
      stop
    end

  end

  def stop
  
    # finalize stuff
    @pc = Job.COMPLETED
    log "STOP", { location: cookies[:location] ? cookies[:location] : 'undefined' }

    # tell manta we're done
    Thread.new do
      uri = URI("http://istc.cs.washington.edu:8800/stop?&job=#{@job.id}&server=" + Socket.gethostname + ":" + request.port.to_s + "&abort=" + ( @exception ? 'true' : 'false' ))
      res = Net::HTTP.get(uri)
      logger.info "Message from MANTA on stop: " + res
    end

  end

  def clear_params
    #
    # This method removes keys from the query string so they don't get used again when
    # the program counter steps to the next instruction.
    #
    params.delete :new_item_id
    params.delete :location
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
          process_error "Error executing #{@instruction.name}: " + e.to_s + ', ' + e.backtrace.to_s
          render 'current'
          return
        end
      else
        start
      end

      # continue through instructions that are not renderable
      if @pc < @protocol.program.length 

        @instruction = @protocol.program[@pc]
        clear_params     

        while !@instruction.renderable && @pc < @protocol.program.length && ! @instruction.respond_to?( :stop )
          begin
            execute
          rescue Exception => e
            process_error "Error executing #{@instruction.name}: " + e.to_s + ', ' + e.backtrace.to_s
            render 'current'
            return
          end
          if @pc < @protocol.program.length && ! @instruction.respond_to?( :stop )
            @instruction = @protocol.program[@pc] 
            clear_params
          end
          
        end

      end

      # check if protocol is finished
      if @pc < @protocol.program.length && ! @instruction.respond_to?( :stop )
        @instruction = @protocol.program[@pc]
        clear_params
      else
        stop
      end

      @job.pc = @pc
      @job.state = { stack: @scope.stack }.to_json
      @job.save

      if @pc != Job.COMPLETED
        pre_render
      end
  
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

  def release
    i = Item.find_by_id(params[:item])
    if i
      i.inuse = 0
      i.save
      flash[:success] = "Item #{params[:item]} has been released."
    end
    current
  end

end
