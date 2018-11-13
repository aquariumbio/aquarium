class PublishController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index
    render layout: 'aq2'
  end

  def check_repo # This should be moved to aquadoc

    resp = AqResponse.new

    if !params[:repo] || params[:repo].length == 0
      resp.error("A Github repository name must contain at least one character.")     
    else
      begin
        client = Octokit::Client.new(:access_token => params[:access_token])
        logger.info "Rate Limit Info: #{client.rate_limit}"
        repos = client.repositories.collect { |r| r.name }
      rescue Exception => e
        resp.error("Aquarium cannot access Github using the supplied access token.", e)
      else
        if repos.member?(params[:repo])
          begin
            file = client.contents({ repo: params[:repo], user: params[:user]}, path: "/config.json")
            config = Base64.decode64(file[:content])
          rescue Exception => e
            resp.error("The Github repository '#{params[:repo]}' exists but does not contain a config.json file.", e)
          else
            resp.ok(repo_exists: true, config: config)
          end
        else
          resp.ok(repo_exists: false)
        end
      end
    end

    render json: resp

  end

  def publish

    resp = AqResponse.new

    if params[:categories]

      categories = params[:categories].collect do |category|
        category[:members].collect do |member|
          if member[:model][:model] == "Library"
            Library.find(member[:id]).export
          else
            ex = OperationType.find(member[:id]).export
            puts "#{ex[:operation_type][:name]} ==> #{ex[:object_types]}"
            ex
          end
        end
      end

      Thread.new do
        ag = Aquagit.new(params[:config], categories)
        ag.run
      end

      resp.ok

    else

      resp.error("No operation types selected.")

    end

    render json: resp

  end

  def ready

    resp = AqResponse.new
    client = Octokit::Client.new(:access_token => params[:access_token])

    begin
      file = client.contents({ repo: params[:repo], user: params[:user]}, path: "/config.json")
      logger.info "Rate Limit Info: #{client.rate_limit}"
      config = Base64.decode64(file[:content])
      puts config.to_json
    rescue Exception => e
      puts e.to_s
      resp.ok(ready: false)
    else
      resp.ok(ready: true)
    end

    render json: resp

  end

end