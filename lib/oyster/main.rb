# frozen_string_literal: true

require_relative 'interface'
require_relative 'place'
require_relative 'transition'
require_relative 'wire'
require_relative 'metacol'

require_relative '../lang/lang'
require_relative 'parser'
require_relative 'parse_place'
require_relative 'parse_trans'
require_relative 'parse_wire'
require_relative 'parse_args'
require_relative 'time'

p = Oyster::Parser.new(File.read('./lib/oyster/examples/1.oy'))
m = p.parse

m.start nmax: 2
s = m.state.to_json

loop do

  sleep 1

  m = Oyster::Parser.new(File.read('./lib/oyster/examples/1.oy')).parse
  m.set_state(JSON.parse(s, symbolize_names: true))
  m.update
  s = m.state.to_json

  exit if m.done?

end
