require './plankton'

p = Plankton::Parser.new File.read ARGV.shift 

p.parse

puts p.args
puts '-----------------'
p.show
