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

    logger.debug "SUBTREE: attempting to get tree"

    begin
      @github = (@client.tree 'klavinslab/protocols', @sha )
    rescue
      logger.debug "SUBTREE: failed to get tree"
      flash.now[:error] = "could not get github tree"
      @github = nil
    end

    if @github
      logger.debug "SUBTREE: sucessfully retreived tree #{@github.inspect}"
      @tree = @github.tree
    else
      @tree = []
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

    if params[:open] == 'no'

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

      logger.debug "SUBTREE: closeing a subtree"
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
    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    @protocol = Base64.decode64(client.blob('klavinslab/protocols',@sha).content);

    respond_to do |format|
      format.html
      format.xml { render xml: @protocol }
    end

  end

  def pretty

    @sha = params[:sha]
    @path = params[:path]
    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    @protocol = Base64.decode64(client.blob('klavinslab/protocols',@sha).content);

    respond_to do |format|
      format.html
    end

  end

  def parse

    @sha = params[:sha]
    @path = params[:path]
    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    file = Base64.decode64(client.blob('klavinslab/protocols',@sha).content);

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
