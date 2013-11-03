require './meta'
require './tokenizer'
require './parser'
require './strings'
require './arguments'
require './steps'
require './assignments'
require './expressions'

p = Plankton::Parser.new File.read ARGV.shift 

begin
  p.parse
rescue Exception => e
  puts "Parse error: #{e}"
end

