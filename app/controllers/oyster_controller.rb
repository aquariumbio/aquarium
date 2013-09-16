class OysterController < ApplicationController

  #
  # Attempts to find the protocol, parse the protocol, and submit the job.
  # Returns the job number of the submitted protocol, or an error.
  #
  def submit

    sha = params[:sha]
    path = params[:path]
    error = false
    error_msg = ""

    begin
      blob = Blob.get sha, params[:path]
      file = ( blob ).xml
    rescue Exception => e
      error = true
      error_msg += "Could not find protocol by sha. " 
    end
   
    protocol = Protocol.new

    begin
      protocol.parse_xml file
    rescue Exception => e
      error = true
      error_msg += "Could not parse xml. "
    end

    begin
      protocol.parse
    rescue Exception => e
      error = true
      error_msg = "Could not parse pdl. "
    end

    begin
      user_id = User.find_by_login params[:login]
    rescue Exception => e
      error = true
      error_msg = "Could not find user #{params[:login]}. "
    end

    unless error

      scope = Scope.new {}

      # push arguments
      protocol.args.each do |a|
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

      job = Job.new
      job.sha = sha
      job.path = blob.path
      job.user_id = user_id
      job.pc = Job.NOT_STARTED
      job.state = { stack: scope.stack }.to_json
      job.save

      render json: { action: "submit", job: job.id } 

    else

      render json: { action: "submit", error: error_msg } 

    end

  end

  #
  # Returns the pc of the job, or an error if the job is not found. Note that pc=-1 means the job
  # has not yet started, and pc=-2 means the job is done. 
  # 
  def status

    error = false

    begin
      j = Job.find(params[:job].to_i)
    rescue Exception => e
      error = true
      error_msg = "Could not parse xml. "
    end

    if error 
      render json: { action: "status", error: error_msg } 
    else
      render json: { action: "status", pc: j.pc }
    end

  end

  def cancel

   respond_to do |format|
      format.html
      format.json { render json: { action: "cancel" } } 
    end

  end

  def log

    error = false

    begin
      j = Job.find(params[:job].to_i)
    rescue Exception => e
      error = true
      error_msg = "Could not parse xml. "
    end

    if error 
      render json: { action: "log", error: error_msg } 
    else
      render json: { action: "log", log: j.logs }
    end

  end

  #
  # Responds with a bit of information so you can see if the server is running.
  #
  def ping

    respond_to do |format|
      format.html
      format.json { render json: { action: "ping", host: request.host_with_port, env: Rails.env } }
    end

  end

end
