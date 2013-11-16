require_relative 'place'
require_relative 'transition'
require_relative 'wire'
require_relative 'metacol'
require_relative 'interface'

include Oyster

m = Metacol.new

p1 = m.place Place.new.proto('plankton/one.pl').mark
p2 = m.place Place.new.proto('plankton/two.pl')

m.transition Transition.new.parent(p1).child(p2).cond("completed(0)")
m.transition Transition.new.parent(p2).child(p1).cond("completed(0)")

m.wire p1, "n", p2, "x"

m.start

while true
  sleep 1
  m.update
end





