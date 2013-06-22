class ProtocolTreeController < ApplicationController

  before_filter :signed_in_user

  def home

    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    @commits = client.list_commits('klavinslab/protocols')
    @tree = (client.tree 'klavinslab/protocols', @commits.first.sha ).tree
    @sha = @commits.first.sha 

  end

  def subtree

    @sha = params[:sha]

    if params[:open] == 'no'
      client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
      @tree = (client.tree 'klavinslab/protocols', @sha ).tree
    else 
      @tree = [];
    end

    respond_to do |format|  
      format.html 
      format.js   { render( partial: 'protocol_tree/subtree.js.erb', formats: :js, remote: true ) }
    end

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
