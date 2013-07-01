require './lib/pdl'

s = Scope.new

url = 'http://bioturk.ee.washington.edu:3000/liaison/'

  uri = URI(url+'info.json')
  uri.query = URI.encode_www_form({name:'1000 mL Bottle'})
  result = Net::HTTP.get_response(uri)
  obj = JSON.parse(result.body, {:symbolize_names => true})

  uri = URI(url+'take.json')
  uri.query = URI.encode_www_form({ id: 45, quantity: 1 })
  result = Net::HTTP.get_response(uri)
  i1 = JSON.parse(result.body, {:symbolize_names => true})

  uri = URI(url+'take.json')
  uri.query = URI.encode_www_form({ id: 45, quantity: 1 })
  result = Net::HTTP.get_response(uri)
  i2 = JSON.parse(result.body, {:symbolize_names => true})

  s.set :y, 12
  s.set :x, [ PdlItem.new( obj, i1 ), PdlItem.new( obj, i2 ) ]

e = "%{x}[0]" 

p s.evaluate e







