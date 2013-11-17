require_relative 'interface'
require_relative 'place'
require_relative 'transition'
require_relative 'wire'
require_relative 'metacol'

require_relative '../lang/lang'
require_relative 'parser'

#p = Oyster::Parser.new( File.read ARGV.shift )

p = Oyster::Parser.new( File.read './lib/oyster/examples/1.pl' )
#p = Oyster::Parser.new( File.read 'examples/1.pl' )

m = p.parse
puts "#{m.places.length} places"
m.start

# include Oyster

# m = Metacol.new.who('klavins')

# p1 = m.place Place.new.proto('plankton/one.pl').group('admin').mark
# p2 = m.place Place.new.proto('plankton/two.pl').group('klavins')

# m.transition Transition.new.parent(p1).child(p2).cond("completed(0)")
# m.transition Transition.new.parent(p2).child(p1).cond("completed(0)")

# m.wire p1, "n", p2, "x"

# m.start

# while true
#   sleep 1
#   m.update
# end





