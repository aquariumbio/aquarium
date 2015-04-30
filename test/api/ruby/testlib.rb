require 'net/http' 
require 'json'

module Test

  @@report = false

  def self.login 
    "klavins"
  end

  def self.key 
    if ARGV[0] == "r"
      "mT6wiyfYoAtY-8rJMmRqh8QgRTTcNrrTbKiHSOzPocI"      
    else
      "fVcQ53G4v1vAZZYsh3UmLRbASBvGa72wkOofFdxqERE"
    end
  end

  def self.url

    if ARGV[0] == "r"
      u = 'http://bioturk.ee.washington.edu:3011/api'      
    else    
      u = 'http://localhost:3000/api'
    end
    puts
    puts "Connecting to #{u}" unless @@report
    @@report = true
    u
  end

  def self.send data
    uri = URI(url)  
    http = Net::HTTP.new(uri.host,uri.port)
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = data.to_json
    res = http.request(req)
    JSON.parse(res.body,symbolize_names: true)
  end

  def self.report val
    if val
      "\t ... \e[0;32mpassed\e[0m"
    else
      "\t ... \e[0;31mfailed\e[0m"
    end
  end

  def self.verify name, query, opts={}

    print "#{name}"
    answer = send query
    puts " --> #{answer} " if opts[:loud]

    puts " error: #{answer[:errors].join(', ')}" if answer[:result] == "error"

    begin
      result = yield answer
    rescue
      result = false
    end

    puts report result
    
  end

end