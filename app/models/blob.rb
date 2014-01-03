class Blob < ActiveRecord::Base

  attr_accessible :path, :sha, :xml, :dir, :job_id

  def self.get sha, path

    b  = self.find_by_sha ( sha )

    if !b 

      if !/local/.match sha

        logger.info "Connecting to github to get #{sha}"

        client = Octokit::Client.new(login:Bioturk::Application.config.repo_user,password:Bioturk::Application.config.repo_password)

        b = self.new
        b.sha = sha
        b.path = path
        b.xml = Base64.decode64(client.blob(Bioturk::Application.config.protocol_repo,sha).content);
        b.save

      else

        b = Blob.new

      end

    end

    return b

  end

  def self.get_tree sha
  
    b  = self.find_by_sha ( sha )

    if b
 
      result = YAML.load(b.dir).tree

    else 

      client = Octokit::Client.new(login: Bioturk::Application.config.repo_user, password: Bioturk::Application.config.repo_password)
      gh = (client.tree Bioturk::Application.config.protocol_repo, sha)

      b = self.new
      b.sha = sha
      b.dir = gh.to_yaml
      b.save

      result = gh.tree

    end

    return result

  end

  def self.get_file job_id, fullpath

    logger.info "#########get_file called with job_id = #{job_id}"

    if job_id < 0 # not called from a job
      blist = []
    else
      logger.info "#########seeing if blobs are available for job #{job_id.to_s}"
      blist = self.where("job_id = :j AND path = :p", { j: job_id, p: fullpath })
      logger.info "#########found #{blist.length} blobs"
    end

    if blist.length != 1

      # Ask github for the protocol
      logger.info "#########Connecting to github to get sha #{fullpath} for job #{job_id} because blist.length = #{blist.length}."
      client = Octokit::Client.new(login: Bioturk::Application.config.repo_user, password: Bioturk::Application.config.repo_password)
      file = client.contents Bioturk::Application.config.protocol_repo, :path => fullpath
      logger.info "#########Done getting blob sha: #{file.sha} for job " + job_id.to_s

      # make a new blob
      b = self.new
      b.sha = file.sha
      b.path = fullpath
      b.job_id = job_id
      b.xml = Base64.decode64(client.blob(Bioturk::Application.config.protocol_repo, file.sha).content);

      # only store if called from a job
      if job_id >= 0
        logger.info "#########storing blob"
        b.save
      end

    else 

      b = blist.first

    end

    logger.info "#########Returning blob"

    return { content: b.xml, sha: b.sha }

  end

end
