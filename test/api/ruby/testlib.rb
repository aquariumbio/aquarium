require 'net/http' 
require 'json'

module Test

  def self.login 
    "klavins"
  end

  def self.key 
   "fVcQ53G4v1vAZZYsh3UmLRbASBvGa72wkOofFdxqERE"
  end

  def self.send data
    uri = URI('http://localhost:3000/api')  
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
    puts " --> #{result} " if opts[:loud]

    begin
      result = yield answer
    rescue
      result = false
    end

    puts report result
    
  end

end