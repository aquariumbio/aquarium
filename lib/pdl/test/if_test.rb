# frozen_string_literal: true

require './lib/pdl'

proto = Protocol.new
proto.open 'examples/if_test.xml'
proto.parse
proto.program.each { |i| puts i.name }

puts "\nInterpreter \n-------------------------------"
interp = Interpreter.new proto, {}
interp.step
interp.step
interp.step
interp.step
interp.step
