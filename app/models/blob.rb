class Blob < ActiveRecord::Base

  attr_accessible :path, :sha, :xml, :dir

  def self.get sha, path

    b  = self.find_by_sha ( sha )

    if !b 

      client = Octokit::Client.new(login:'klavins',password:'a22imil@te')

      b = self.new
      b.sha = sha
      b.path = path
      b.xml = Base64.decode64(client.blob('klavinslab/protocols',sha).content);
      b.save

    end

    return b

  end

  def self.get_tree sha
  
    b  = self.find_by_sha ( sha )

    if b
 
      result = YAML.load(b.dir).tree

    else 

      client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
      gh = (client.tree 'klavinslab/protocols', sha)

      b = self.new
      b.sha = sha
      b.dir = gh.to_yaml
      b.save

      result = gh.tree

    end

    return result

  end

  def self.get_file fullpath

    client = Octokit::Client.new(login:'klavins',password:'a22imil@te')
    file = client.contents 'klavinslab/protocols', :path => fullpath
    { content: ( Base64.decode64 (client.blob 'klavinslab/protocols', file.sha ).content ), sha: file.sha }

  end

end
