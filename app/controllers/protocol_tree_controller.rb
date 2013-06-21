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

    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    @tree = (client.tree 'klavinslab/protocols', @sha ).tree

    respond_to do |format|  
      format.html 
      format.js   { render( partial: 'protocol_tree/subtree.js.erb', formats: :js, remote: true ) }
    end

  end

  def raw
  end

end
