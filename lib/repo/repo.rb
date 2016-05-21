module Repo

  def self.base directory
    "repos/#{directory}/"
  end

  def self.repo_name path
    if path[0] == "/"
      path.split('/')[1]      
    else
      path.split('/')[0]
    end
  end

  def self.basic_path path
    if path[0] == "/"
      path.split('/')[2..-1].join('/')      
    else
      path.split('/')[1..-1].join('/')
    end
  end

  def self.version path, directory='master', branch='master'
   
    puts "Version #{base(directory) + (repo_name path)} : #{branch}"

    begin
      git = Git.open(base(directory) + (repo_name path))
      git.branch(branch).checkout
    rescue Exception => e
      raise "Repo Module could not find or open the repository named '#{repo_name path}': #{e.to_s}"
    end

    begin
      object = git.object( ":" + (basic_path path))
    rescue Exception => e
      raise "Repo Module could not find #{basic_path path} in #{repo_name path}"
    end

    object.sha

  end

  def self.contents path, sha, directory='master', branch='master'

    puts "Contents #{base(directory) + (repo_name path)} : #{branch}"    

    begin
      git = Git.open(base(directory) + (repo_name path))
      git.branch(branch).checkout      
      object = git.object(sha)
      object.contents
    rescue Exception => e
      puts e.to_s
      raise e
    end

  end

  def self.info name, directory='master', branch='master'

    puts "Info #{base(directory)}, #{name}, #{branch}"

    git = Git.open(base(directory) + (name))
    git.branch(branch).checkout    

    {
      date:    git.log.first.date,
      message: git.log.first.message,
      who:     git.log.first.committer.name,
      branch:  branch
    }

  end

  def self.save path, content, directory='master', branch='master'

    puts "Save #{base(directory) + (repo_name path)} : #{branch}"    

    git = Git.open(base(directory) + (repo_name path))
    git.branch(branch).checkout  

    file = File.open(base(directory) + path, "w");
    file.puts content
    file.close

    git.add
    git.commit "Updated #{path}"
    object = git.object( ":" + (basic_path path))

    begin
      result = git.push(git.remote('origin'),branch)
    rescue Exception => e 
      Rails.logger.info "Repo module could not pull/push"
    end

    object.sha

  end

end
