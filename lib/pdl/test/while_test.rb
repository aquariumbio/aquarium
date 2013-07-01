require './lib/pdl'

proto = Protocol.new 
proto.open 'examples/while_test.xml'

proto.parse
proto.program.each { |i| puts i.name }

puts "\nInterpreter \n-------------------------------"
interp = Interpreter.new proto, {} 
interp.run
