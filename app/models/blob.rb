# frozen_string_literal: true

class Blob < ActiveRecord::Base

  # Note: Blobs used to be used to cache local copies of things from github or local files. The new
  # scheme is to have local github repos, so blobs are not used for that anymore. They only use for
  # blobs at this point is to remember the content of protocols launched from local files.

  attr_accessible :path, :sha, :xml, :dir, :job_id

  def self.get(sha, _path)

    b = find_by_sha sha

    unless b

      if !/local/.match sha

        raise 'Attempt to get blob from github via old octokit method, which has been removed and replaced with this message.'

      else

        b = Blob.new

      end

    end

    b

  end

  def self.get_tree(sha)

    b = find_by_sha sha

    if b

      result = YAML.load(b.dir).tree

    else

      client = Octokit::Client.new(login: Bioturk::Application.config.repo_user, password: Bioturk::Application.config.repo_password)
      gh = (client.tree Bioturk::Application.config.protocol_repo, sha)

      b = new
      b.sha = sha
      b.dir = gh.to_yaml
      b.save

      result = gh.tree

    end

    result

  end

  def self.get_file(job_id, fullpath)

    blist = if job_id < 0 # not called from a job
              []
            else
              where('job_id = :j AND path = :p', j: job_id, p: fullpath)
            end

    if blist.length != 1

      # Ask github for the protocol
      client = Octokit::Client.new(login: Bioturk::Application.config.repo_user, password: Bioturk::Application.config.repo_password)
      file = client.contents Bioturk::Application.config.protocol_repo, path: fullpath

      # make a new blob
      b = new
      b.sha = file.sha
      b.path = fullpath
      b.job_id = job_id
      b.xml = Base64.decode64(client.blob(Bioturk::Application.config.protocol_repo, file.sha).content)

      # only store if called from a job
      b.save if job_id >= 0

    else

      b = blist.first

    end

    { content: b.xml, sha: b.sha }

  end

end
