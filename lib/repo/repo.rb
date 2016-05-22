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

    Rails.logger.info "Repo::save: Opening repo #{base(directory) + (repo_name path)} : #{branch}"    

    git = Git.open(base(directory) + (repo_name path))
    git.branch(branch).checkout  

    Rails.logger.info "Repo::save: Branches:\n#{git.branches}"
    Rails.logger.info "Repo::save: Opening file #{base(directory) + path}"       

    file = File.open(base(directory) + path, "w");
    file.puts content
    file.close

    Rails.logger.info "Repo::save: Adding file #{base(directory) + path}"   

    git.add 

    Rails.logger.info "Repo::save: Committing"     

    git.commit "Repo::save: Updated #{path} via the Aquarium developer tool."
    object = git.object( ":" + (basic_path path))

    Rails.logger.info "Repo::save: Pushing"     

    begin
      result = git.push(git.remote('origin'),branch)
    rescue Exception => e 
      Rails.logger.info "Repo::save: Repo module could not pull/push"
    end

    Rails.logger.info "Repo::save: Done"

    object.sha

  end

end
