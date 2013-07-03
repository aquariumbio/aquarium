class InterpreterController < ApplicationController

  def parse

    @sha = params[:sha]
    @path = params[:path]
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

    parse

    respond_to do |format|
      format.html
    end

  end

  def submit

    parse
    scope = Scope.new

    @protocol.args.each do |a|
      scope.set a.var.to_sym, params[a.var.to_sym]
    end

    @job = Job.new
    @job.sha = @sha
    @job.path = @path
    @job.user_id = current_user.id
    @job.state = { pc: 0, scope: scope }.to_json
    @job.save

    respond_to do |format|
      format.html
    end

  end

  def next
  end

  def abort
  end

end
