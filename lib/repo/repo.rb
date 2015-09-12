module Repo

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

    Thread.new do  

      begin

        Rails.logger.info "DEFAULT PROTOCOL: Copying #{from} to #{to}."

        system "cp repos/#{from} repos/#{to}"
        raise "DEFAULT PROTOCOL: Could not create new protocol file: #{$?}" unless $? == 0

        Rails.logger.info "DEFAULT PROTOCOL: Copied default protocol."

        begin
          git = Git.open("repos/" + (repo_name from))
        rescue Exception => e
          Rails.logger.info "DEFAULT PROTOCOL: failed to open repo (#{repo_name from}): #{e.to_s}"
        end

        Rails.logger.info "DEFAULT PROTOCOL: opened #{repo_name from}"

        begin
          Rails.logger.info "DEFAULT PROTOCOL: adding ... "
          git.add
          Rails.logger.info "DEFAULT PROTOCOL: ... added."
        rescue Exception => e
          Rails.logger.info "DEFAULT PROTOCOL: Error in default copy routine (could not open/add #{basic_path to}): #{e.to_s}"
        end

        Rails.logger.info "DEFAULT PROTOCOL: added #{basic_path to}."

        git.commit("Created generic protocol for operation #{to.split('/').last.split('.').first}")

        Rails.logger.info "DEFAULT PROTOCOL: committed changes to #{repo_name from}"

        begin
          git.pull(git.remote('origin'))
          git.push(git.remote('origin'))
        rescue Exception => e 
          Rails.logger.info "DEFAULT PROTOCOL: Error in default copy routine. Not master repo found. #{e.to_s}"
        end

        Rails.logger.info "DEFAULT PROTOCOL: Completed protocol default copy routine."      

      rescue Exception => e

        Rails.logger.info "DEFAULT PROTOCOL ERROR: #{e.to_s}, #{e.backtrace.join('\n')}"

      end

    end

  end

end
