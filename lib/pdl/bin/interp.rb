require './lib/pdl'

proto = Protocol.new 
proto.open ARGV.shift
proto.parse

proto.show

gets 
interp = Interpreter.new proto, {} 
interp.run
