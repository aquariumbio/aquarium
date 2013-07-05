class InformationInstruction < Instruction

  attr_reader :content

  def initialize content
    super 'information'
    @content = content
    @renderable = true
  end

  def render scope
    puts "Protocol Information"
    puts scope.substitute content
    print "\nPress [ENTER] to continue: "
  end

  def execute scope
    gets
  end

end


