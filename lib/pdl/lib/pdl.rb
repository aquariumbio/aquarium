require './lib/protocol'
require './lib/scope'
require './lib/interpreter'
require './lib/pdl_item'

Dir["./lib/*instruction.rb"].each { |file| require file }
