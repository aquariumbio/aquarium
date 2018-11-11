class PublishController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index

    render layout: 'aq2'

  end

  def check_repo # This should be moved to aquadoc

    if !params[:repo] || params[:repo].length == 0
      render json: { result: "error", message: "A Github repository name must contain at least one character.", error: "" }
      return     
    end

    begin
      client = Octokit::Client.new(:access_token => params[:access_token])
      repos = client.repositories.collect { |r| r.name }
      user = client.user()
    rescue Exception => e
      render json: { result: "error", message: "Could not use access token to access Github account.", error: e.to_s }
      return
    end

    if repos.member?(params[:repo])

      begin
        contents = client.contents({ repo: params[:repo], user: params[:user]}, path: "/config.json")
        config = Base64.decode64(file[:content])
      rescue Exception => e
        render json: { result: "error", message: "Repo exists but does not contain a config.json file.", error: e.to_s }
        return
      end
      render json: { result: "ok", repo_exists: true, config: config }

    else

      render json: { result: "ok", repo_exists: false }

    end

  end

end