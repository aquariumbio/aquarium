# frozen_string_literal: true

class PublishController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def index
    render layout: 'aq2'
  end

  def check_repo # This should be moved to aquadoc
    resp = AqResponse.new

    github_user = params[:organization] || params[:user]

    if !params[:repo] || params[:repo].length == 0
      resp.error("A Github repository name must contain at least one character.")
    else
      begin
        client = Octokit::Client.new(:access_token => params[:access_token])
        logger.info "Rate Limit Info: #{client.rate_limit}"
        repos = client.repositories(github_user).collect { |r| r.name }
        logger.info(repos)
      rescue StandardError => e
        logger.info(e)
        resp.error("Aquarium cannot access Github using the supplied access token.", e)
      else
        if repos.member?(params[:repo])
          begin
            file = client.contents({ repo: params[:repo], user: github_user }, path: "/config.json")
            config = JSON.parse Base64.decode64(file[:content])
            file = client.contents({ repo: params[:repo], user: github_user }, path: "/#{params[:repo]}.aq")
            aq_file = JSON.parse Base64.decode64(file[:content])
          rescue StandardError => e
            resp.error("The Github repository '#{params[:repo]}' exists but does not contain a config.json file.", e)
          else
            resp.ok(repo_exists: true, config: config, aq_file: aq_file)
          end
        else
          resp.ok(repo_exists: false)
        end
      end
    end

    render json: resp
  end

  def categories
    params[:categories].collect do |category|
      category[:members].collect do |member|
        if member[:model][:model] == "Library"
          Library.find(member[:id]).export
        else
          ex = OperationType.find(member[:id]).export
          ex
        end
      end
    end
  end

  def publish
    resp = AqResponse.new
    if params[:categories]
      worker = Anemone::Worker.new(name: "publisher")
      worker.save

      worker.run do
        ag = Aquadoc::Git.new(params[:config], categories)
        ag.run
      end

      resp.ok(worker_id: worker.id)
    else
      resp.error("No operation types selected.")
    end

    render json: resp
  end

  def export
    resp = AqResponse.new
    if params[:categories]
      ar = Aquadoc::Render.new(nil, params[:config], categories)
      resp.ok(aq_file: ar.aq_file)
    else
      resp.error("No operation types selected.")
    end

    render json: resp
  end
end
