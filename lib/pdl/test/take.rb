require './lib/pdl'

t = TakeInstruction.new "1000 mL Bottle", 2, 'x'
r = ReleaseInstruction.new '%{x}[0]'

s = Scope.new

t.render s
t.execute s

r.render s
r.execute s





