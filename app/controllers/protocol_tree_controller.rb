class ProtocolTreeController < ApplicationController

  before_filter :signed_in_user

  def home

    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    @commits = client.list_commits('klavinslab/protocols')
    @tree = (client.tree 'klavinslab/protocols', @commits.first.sha ).tree

  end

  def subtree
    respond_to do |format|  
      format.html #
      format.js   #
    end
  end

  def raw
  end

end
