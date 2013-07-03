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

    respond_to do |format|
      format.html
    end

  end

  def arguments
    parse
  end

  def submit
    parse
  end

  def next
  end

  def abort
  end

end
