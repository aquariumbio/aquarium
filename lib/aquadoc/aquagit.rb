require 'octokit'
require 'base64'

class Aquagit

  attr_accessor :authorized

  def initialize config, categories, opts = {}
    @opts = opts
    @config = config
    @repo = nil
    @repo_info = { repo: @config[:github][:repo], user: @config[:github][:user] }
    @access_token = config[:github][:access_token]
    @authorized = authenticate
    @create = nil
    @categories = categories

    system "git config --global user.email 'info@aquarium.com'"
    system "git config --global user.name 'Aquadoc'"

  end

  def run

    aquadoc = Aquadoc.new(self, @config, @categories)

    if !repo
      create_repo
      @create = true
    else
      @create = false
    end

    aquadoc.make(@opts.merge(init: @create))

  end

  def write path, content

    print path.split("/").last + " "

    if @create
      begin
        @client.create_contents(@repo_info, path, "Aquadoc initial commit", content)
      rescue Exception => e
        puts "Warning: Could not create #{path}: #{e}"
      end
    else
      begin
        file = @client.contents(@repo_info, path: path)
        if Base64.decode64(file[:content]) != content
          @client.update_contents(@repo_info, path, "Aquadoc update", file[:sha], content)
        end
      rescue Exception => e
        puts "Warning: #{e}"
        @client.create_contents(@repo_info, path, "Aquadoc created file", content)
      end
    end

  end

  def authenticate

    begin
      @client = Octokit::Client.new(:access_token => @access_token)
      return true
    rescue
      return false
    end

  end

  def repo
    begin
      @repo ||= @client.repository(@repo_info)
    rescue Exception => e
      @repo = nil
    end
    @repo
  end

  def create_repo
    @repo = @client.create_repository(@repo_info[:repo], description: "An Aquarium Workflow")
  end

  def clone_repo
    system "git clone https://github.com/#{@repo_info[:user]}/#{@repo_info[:repo]}.git"
  end

  def add_and_commit
    system "(cd #{@repo_info[:repo]}; git add .; git commit -m 'Aquadoc update')"
  end

  def push_changes

  end

end
