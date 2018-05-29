require './lib/pdl'

puts "\nProtocol    \n--------------------------------"
proto = Protocol.new
proto.open('examples/test.xml')
proto.parse
proto.program.each { |i| puts i.name }

puts "\nScope       \n--------------------------------"

str = 'x = %{x} and y = %{y}'
s = Scope.new

s.set :x, 1
s.set :y, 2
puts s.substitute str

s.push
s.set :x, 3
puts s.substitute str

puts "scope:\n" + s.to_s
s.pop

puts s.substitute str
puts "scope:\n" + s.to_s

puts "\nInterpreter \n-------------------------------"
interp = Interpreter.new proto, {}
interp.step
interp.step
interp.step
interp.step
