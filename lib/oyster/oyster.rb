require_relative 'interface'
require_relative 'place'
require_relative 'transition'
require_relative 'wire'
require_relative 'metacol'

require_relative '../lang/lang'
require_relative 'parser'

p = Oyster::Parser.new( File.read './lib/oyster/examples/1.oy' )
#p = Oyster::Parser.new( File.read 'examples/1.oy' )

m = p.parse

puts m.to_s

m.start

while true
  sleep 1
  m.update
end





