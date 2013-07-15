class ProtocolTreeController < ApplicationController

  before_filter :signed_in_user

  def get_client

   logger.debug "SUBTREE: attempting to get client"

    begin
      @client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    rescue
      logger.debug "SUBTREE: failed to get client"
      flash.now[:error] = "could not set up github client"
      @client = nil
    end

    if @client
      logger.debug "SUBTREE: successfully retrieved client #{@client.inspect}"
    end

  end

  def get_subtree 

    begin
      @tree = Blob.get_tree @sha
    rescue Exception => e
      logger.debug "SUBTREE: failed to get tree: " + e.message
      flash.now[:error] = "could not get github tree: " + e.message
      @github = nil
    end

  end

  def get_commits

    logger.debug "SUBTREE: attempting to get commits"

    begin
      @commits = @client.list_commits('klavinslab/protocols')
    rescue
      @logger.debug "SUBTREE: could not get commits"
      @commits = nil
    end

    if @commits
      logger.debug "SUBTREE: successfully retrieved commits"
    end

  end

  def subtree

    logger.debug "SUBTREE: start"

    @sha = params[:sha]

    if @sha && params[:open] == 'no'

      @tree = Blob.get_tree @sha

    elsif params[:open] == 'no'

      get_client
      if @client
        if !@sha
          get_commits
          if @commits
            @sha = @commits.first.sha
            get_subtree
          else
            @github = nil
            @tree = []
          end
        else
          get_subtree
        end
      else
        @github = nil
        @tree = []  
      end

    else 

      if !params[:sha]
        @sha = 'root'
        logger.debug "SUBTREE: closing root"
      end

      logger.debug "SUBTREE: closing a subtree"
      @tree = []

    end

    respond_to do |format|  
      format.html 
      format.js   { logger.debug render( partial: 'protocol_tree/subtree.js.erb', formats: :js, remote: true ).inspect }
    end

    logger.debug "SUBTREE: end"

  end

  def home
  end

  def raw

    @sha = params[:sha]
    @protocol = ( Blob.get @sha, '' ).xml

    respond_to do |format|
      format.html
      format.xml { render xml: @protocol }
    end

  end

  def pretty

    @sha = params[:sha]
    @path = params[:path]
    @protocol = ( Blob.get @sha, @path ).xml

    respond_to do |format|
      format.html
    end

  end

  def parse

    @sha = params[:sha]
    @path = params[:path]
    file = ( Blob.get @sha, @path ).xml

    @protocol = Protocol.new
    @errors = ""

    begin
      @protocol.parse_xml file
    rescue Exception => e
      @errors = e
    end

    begin
      @protocol.parse
    rescue Exception => e
      @errors = e
    end

    respond_to do |format|
      format.html
    end

  end

end
