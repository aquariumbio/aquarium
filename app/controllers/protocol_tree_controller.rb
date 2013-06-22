class ProtocolTreeController < ApplicationController

  before_filter :signed_in_user

  def home
    @tree = [];
  end

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

    if !@sha

      get_client

      if ( @client )

        get_commits

        if @commits
          @sha = @commits.first.sha
          get_subtree
        else
          @tree = []
        end

      else
        @tree = []
      end

    elsif params[:open] == 'no'

      get_client

      if @client
        get_subtree
      else
        @github = nil
        @tree = []  
      end

    else 

      @tree = []

    end

    logger.debug "SUBTREE: middle"

    respond_to do |format|  
      format.html 
      format.js   { render( partial: 'protocol_tree/subtree.js.erb', formats: :js, remote: true ) }
    end

    logger.debug "SUBTREE: end"

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

end
