class AssignInstruction < Instruction

  attr_reader :var, :value

  def initialize lhs, rhs
    super 'assign'
    @lhs = lhs
    @rhs = rhs
    @renderable = false
  end

  # RAILS ###########################################################################################

  def bt_execute scope, params
    scope.set( @lhs.to_sym, scope.evaluate( @rhs ) )
  end

  # TERMINAL #########################################################################################

  def execute scope
    x = scope.evaluate( @rhs )
    puts "setting " + @lhs + " to " + @rhs + " with evaluation " + x.to_s
    scope.set( @lhs.to_sym, x )
  end

end
