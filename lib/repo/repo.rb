module Repo

  def self.repo_name path
    path.split('/')[0]
  end

  def self.basic_path path
    path.split('/')[1..-1].join('/')
  end

  def self.version path
   
    begin
      git = Git.open("repos/" + (repo_name path))
    rescue Exception => e
      raise "Repo Module could not find a repository named '#{repo_name path}'"
    end

    begin
      object = git.object( ":" + (basic_path path))
    rescue Exception => e
      raise "Repo Module could not find #{basic_path path} in #{repo_name path}"
    end

    object.sha

  end

  def self.contents path, sha

    begin
      git = Git.open("repos/" + (repo_name path))
      object = git.object(sha)
      object.contents
    rescue
      (Blob.get sha, path).xml
    end

  end

  def self.info name
    git = Git.open("repos/" + (name))
    {
      date:    git.log.first.date,
      message: git.log.first.message,
      who:     git.log.first.committer.name
    }
  end

  def self.copy from, to
    system "cp repos/#{from} repos/#{to}"
    raise "Could not create new protocol file: #{$?}" unless $? == 0
    git = Git.open("repos/" + (repo_name from))
    git.add(basic_path to)
    git.commit("Created generic protocol for operation #{to.split('/').last.split('.').first}")
    Thread.new do    
      git.pull(git.remote('origin'))
      git.push(git.remote('origin'))
    end
  end

end
