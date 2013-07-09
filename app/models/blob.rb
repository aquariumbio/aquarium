class Blob < ActiveRecord::Base

  attr_accessible :path, :sha, :xml

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

end
