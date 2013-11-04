require './plankton'

p = Plankton::Parser.new File.read ARGV.shift 


p.statement_list

puts p.args
puts '-----------------'
p.show
