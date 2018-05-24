class OysterController < ApplicationController

  before_filter :signed_in_user

  ######################################################################################################################
  # JOBS INTERFACE                                                                                                     #
  ######################################################################################################################

  #
  # Attempts to find the protocol, parse the protocol, and submit the job.
  # Returns the job number of the submitted protocol, or an error.
  #
  def submit

    error = false
    error_msg = ""

    if params[:sha]

      begin
        sha = params[:sha]
        blob = Blob.get sha, ""
        file = (blob).xml
      rescue Exception => e
        error = true
        error_msg += "Could not find protocol by sha. "
      end

    elsif params[:path]

      begin
        path = params[:path]
        b = Blob.get_file -1, path
        file = b[:content]
        sha = b[:sha]
      rescue Exception => e
        error = true
        error_msg += "Could not find protocol with path #{params[:path]}. " + e.to_s + ". " + "Here, b = " + b.to_s + ". "
      end

    else

      error = true
      error_msg += "Could not find protocol because neither the path nor the sha were specified."

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
      job.path = path
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

  def convert_log log
    log.attributes.merge({ data: JSON.parse(log.data) })
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
      render json: { action: "log", log: j.logs.map { |l| convert_log l } }
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

  ######################################################################################################################
  # INVENTORY INTERFACE                                                                                                #
  ######################################################################################################################

  #
  # Returns basic information about the object, if it exists or an error otherwise.
  #

  def info

    error = false

    o = ObjectType.find_by_name(params[:type])

    if !o
      error = true
      error_msg = "Could not find object type #{params[:type]}"
    end

    if error
      render json: { action: "info", error: error_msg }
    else
      render json: { action: "info", info: o.attributes }
    end

  end

  def items

    error = false

    o = ObjectType.find_by_name(params[:type])

    if !o
      error = true
      error_msg = "Could not find object type #{params[:type]}"
    end

    i = o.items.collect { |j| j.attributes }

    if error
      render json: { action: "items", error: error_msg }
    else
      render json: { action: "items", items: i }
    end

  end

end
