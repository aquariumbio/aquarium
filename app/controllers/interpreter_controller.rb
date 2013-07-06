class InterpreterController < ApplicationController

  def parse

    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    file = Base64.decode64(client.blob('klavinslab/protocols',@sha).content);

    @protocol = Protocol.new
    @parse_errors = ""

    begin
      @protocol.parse_xml file
    rescue Exception => e
      @parse_errors = e
    end

    begin
      @protocol.parse
    rescue Exception => e
      @parse_errors = e
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
      scope.set a.var.to_sym, params[a.var.to_sym]
    end

    # push new scope so top level variables are not in same scope as arguments
    scope.push

    @job = Job.new
    @job.sha = @sha
    @job.path = @path
    @job.user_id = current_user.id
    @job.state = { pc: -1, stack: scope.stack }.to_json
    @job.save

    respond_to do |format|
      format.html
    end

  end

  def get_current
 
    # Get the job
    @job = Job.find(params[:job])
    state = JSON.parse(@job.state, {:symbolize_names => true} )

    # Get the protocol
    @sha = @job.sha
    @path = @job.path
    parse

    # Get the pc and scope
    @pc = state[:pc]
    @scope = Scope.new
    @scope.set_stack state[:stack]
    @instruction = @protocol.program[@pc]

  end

  def current

    get_current
    logger.info "current: pc = #{@pc}: #{@instruction.name}"
    logger.info @scope.to_s

  end

  def advance

    get_current

    logger.info "advance: pc = #{@pc}: #{@instruction.name}"
    logger.info @scope.to_s

    # execute the current instruction
    if @pc >= 0
      @instruction.bt_execute @scope, params if @instruction.respond_to?('bt_execute')
      if @instruction.respond_to?("set_pc")
        @pc = ins.set_pc @scope
      else
        @pc += 1
      end
    else
      @pc = 0
    end

    # continue through instructions that are not renderable
    if @pc < @protocol.program.length

      @instruction = @protocol.program[@pc]

      # while instruction at pc is not renderable
      while !@instruction.renderable && @pc < @protocol.program.length

        logger.info "advance: in while loop: #{@instruction.name}."

        # execute the instruction
        @instruction.bt_execute @scope, params if @instruction.respond_to?('bt_execute')

        # increment the pc
        if @instruction.respond_to?('set_pc')
          @pc = @instruction.set_pc @scope
        else
          @pc += 1
        end

        @instruction = @protocol.program[@pc] if @pc < @protocol.program.length

      end

    end

    if @pc < @protocol.program.length

      @job.state = { pc: @pc, stack: @scope.stack }.to_json
      @job.save
      @instruction = @protocol.program[@pc]
      render 'current' #note: this does not call the render method above

    else

      @pc = nil
      @job.state = { pc: @pc, stack: @scope.stack }.to_json
      @job.save
      render 'current'

    end

  end

  def abort
  end

end
