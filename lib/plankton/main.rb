require './plankton'

path = ARGV.shift
contents =  File.read path
p = Plankton::Parser.new( path, contents )

begin
  p.parse
rescue Exception => e
  puts e
  puts e.backtrace
  puts p.get_line
  exit
end

puts p.args
puts '-----------------'
p.show
