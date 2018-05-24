require './plankton'

p = Plankton::Parser.new File.read ARGV.shift

puts p.expr
