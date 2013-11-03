require './plankton'

p = Plankton::Parser.new File.read ARGV.shift 

begin
  p.statement_list
rescue Exception => e
  puts "Plankton encountered a parse error: #{e}"
  exit
end

puts p.args
puts '-----------------'
p.show
