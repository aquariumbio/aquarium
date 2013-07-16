class InterpreterController < ApplicationController

  def parse

    file = ( Blob.get @sha, params[:path] ).xml

    @protocol = Protocol.new
    @parse_errors = ""

    begin
      @protocol.parse_xml file
    rescue Exception => e
      @parse_errors = e.message
    end

    begin
      @protocol.parse
    rescue Exception => e
      @parse_errors = e.message # + ": " + e.backtrace.to_s
    end

  end

  def arguments

    @sha = params[:sha]
    @path = params[:path]
    parse

    respond_to do |format|
      format.html
    end

  end

  def submit

    @sha = params[:sha]
    @path = params[:path]
    parse

    scope = Scope.new {}

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
    @job.user_id = current_user.id
    @job.pc = Job.NOT_STARTED
    @job.state = { stack: scope.stack }.to_json
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

    # Get the pc and scope
    @pc = @job.pc

    @scope = Scope.new
    @scope.set_stack state[:stack]
    @instruction = @protocol.program[@pc]

  end

  def process_error msg
    @exception = true
    @error = msg
    @error_pc = @pc
    @pc = Job.COMPLETED
    @job.pc = @pc
    @job.state = { stack: @scope.stack }.to_json
    @job.save
  end

  def pre_render

    begin
      @instruction.pre_render @scope, params if @instruction.respond_to?('pre_render')
    rescue Exception => e
      process_error "Error in pre_render of " + @instruction.name + ": " + e.to_s
    end  

  end

  def current

    get_current
    pre_render
    render 'current'

  end

  def execute

    if @instruction.respond_to?('bt_execute')
      if @instruction.name == 'log'
        @instruction.bt_execute @scope, params, user: current_user
      else
        @instruction.bt_execute @scope, params
      end
    end

    if @instruction.respond_to?("set_pc")
      @pc = @instruction.set_pc @scope
    else
      @pc += 1
    end

  end

  def advance

    get_current

    if @pc != Job.COMPLETED

      if @pc >= 0
        begin
          execute
        rescue Exception => e
          process_error "Error executing #{@instruction.name}: " + e.to_s + ": "+  e.backtrace.inspect
          render 'current'
          return
        end        
      else
        @pc = 0
      end

      # continue through instructions that are not renderable
      if @pc < @protocol.program.length

        @instruction = @protocol.program[@pc]

        while !@instruction.renderable && @pc < @protocol.program.length
          begin
            execute
          rescue Exception => e
            process_error "Error executing #{@instruction.name}: " + e.to_s
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
        @pc = Job.COMPLETED
      end

      @job.pc = @pc
      @job.state = { stack: @scope.stack }.to_json
      @job.save

      pre_render
  
    end

    render 'current'

  end

  def abort
  end

end
