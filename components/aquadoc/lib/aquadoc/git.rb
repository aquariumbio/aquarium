# typed: true
# frozen_string_literal: true

require 'octokit'
require 'base64'
require 'erb'

module Aquadoc
  class Git
    attr_accessor :authorized

    def initialize(config, categories, opts = {})
      @opts = opts
      @config = config
      @repo = nil
      @repo_info = {
        repo: @config[:github][:repo],
        user: @config[:github][:organization] || @config[:github][:user]
      }
      @access_token = config[:github][:access_token]
      @authorized = authenticate
      @create = nil
      @categories = categories

      system "git config --global user.email 'info@aquarium.com'"
      system "git config --global user.name 'Aquadoc'"
    end

    def run
      aquadoc = Render.new(self, @config, @categories)

      if !repo
        create_repo
        @create = true
      else
        @create = false
      end

      aquadoc.make(@opts.merge(init: @create))
    end

    def write(path, content)
      print path.split('/').last + ' '

      if @create
        create(path: path, message: 'Aquadoc initial commit', content: content)
      else
        begin
          file = @client.contents(@repo_info, path: path)
          return if Base64.decode64(file[:content]) == content
          @client.update_contents(
            @repo_info, path, 'Aquadoc update', file[:sha], content
          )
        rescue StandardError
          create(path: path, message: 'Aquadoc created file', content: content)
        end
      end
    end

    def create(path:, message:, content:)
      @client.create_contents(@repo_info, path, message, content)
    rescue StandardError => error
      puts "Warning: Could not create #{path}: #{error}"
    end

    def authenticate
      # TODO: add error handling
      @client = Octokit::Client.new(access_token: @access_token)
      true
    rescue StandardError
      false
    end

    def repo
      begin
        @repo ||= @client.repository(@repo_info)
      rescue StandardError
        @repo = nil
      end
      @repo
    end

    def create_repo
      user = @config[:github][:user]
      organization = @config[:github][:organization]
      repository = @config[:github][:repo]
      opts = {
        description: "#{@config[:title]}: An Aquarium Workflow",
        homepage: "https://#{organization || user}.github.io/#{repository}/"
      }
      opts[:organization] = organization if organization
      @repo = @client.create_repository(@repo_info[:repo], opts)
      sleep 5 # make sure repo is created before starting to add files
      puts "Created new repo: #{@repo_info[:repo]}"
    end
  end
end
