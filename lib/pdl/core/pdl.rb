require './lib/pdl/core/protocol'
require './lib/pdl/core/scope'
require './lib/pdl/core/interpreter'
require './lib/pdl/core/pdl_item'

Dir["./lib/pdl/core/*instruction.rb"].each { |file| require file }

require './lib/pdl/core/viewer'
