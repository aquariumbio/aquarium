class AssignInstruction < Instruction

  attr_reader :var, :value

  def initialize var, value
    super 'assign'
    @var = var
    @value = value
  end

  def execute scope
    #puts "setting " + @var + " to " + @value + " with substitution " + scope.evaluate(scope.substitute( @value )).to_s
    
    puts "setting " + @var + " to " + @value + " with evaluation " + scope.evaluate( @value ).to_s
    scope.set( var.to_sym, scope.evaluate( @value ) )
  end

end
