require './lib/pdl'
require 'net/http'
require 'json'

def clear
  puts "\e[2J\e[f"
end

def talk verb, args

  uri = URI("http://bioturk.ee.washington.edu:3000/liaison/#{verb}.json")
  uri.query = URI.encode_www_form(args)
  result = Net::HTTP.get_response(uri)
  data = JSON.parse(result.body, {:symbolize_names => true})

  data.each do |k,v|
    if k == :inventory
      puts "    " + k.to_s
      v.each do |i|
        puts "        " + i.to_s
      end
    else
      puts "    #{k}: #{v}"
    end
  end

  data

end

clear

puts "\nTrying produce (v1) \n----------------------------------------------------"
data = talk 'produce', { name:'1000 mL Bottle', location: 'B1.234', quantity: 10 }
i = data[:id]

puts "\nTrying produce (v2) \n----------------------------------------------------"
talk 'produce', { name:'1000 mL Bottle', id: i, quantity: 3 }

puts "\n\n"
puts "\nInfo                \n----------------------------------------------------"
talk 'info', { name:'1000 mL Bottle' }

puts "\nTrying take         \n----------------------------------------------------"
talk 'take', { id: i, quantity: 2 }

puts "\nInfo after take     \n----------------------------------------------------"
talk 'info', { name:'1000 mL Bottle' }

gets

puts "\nTrying release      \n----------------------------------------------------"
talk 'release', { id: i, quantity: 2, method:'return' }

puts "\nInfo after release  \n----------------------------------------------------"
talk 'info', { name:'1000 mL Bottle' }

