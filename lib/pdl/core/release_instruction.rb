class ReleaseInstruction < Instruction

  def initialize expr
    @expr = expr
    super 'release'
  end

  def render scope
 
    @pi = scope.evaluate @expr
    # TODO: check that @pi is a pdl_item

    nm     = @pi.object[:name]
    loc    = @pi.item[:location]
    method = @pi.object[:release_description]

    case @pi.object[:release_method]

      when 'return'
        puts "Please return the #{nm} taken from #{loc}."
        puts "  Details: #{method}"
        print "Press [ENTER] when finished: "

      when 'dispose'
        puts "Please dispose of the #{nm} taken from #{loc}."
        puts "  Details: #{method}"
        print "Press [ENTER] when finished: "

      when 'query'
        puts "Please specify whether the #{nm} taken from #{loc} will be (1) returned or (2) disposed of."
        puts "  Details: #{method}\n\n"
        print "Enter (1) if you returned it or (2) if you disposed of it: "

    end
    
  end

  def execute scope

    input = gets

    if @pi.object[:release_method] == 'query'
      if input.to_i == 1
        method = 'return'
      else
        method = 'dispose'
      end
    else
      method = @pi.object[:release_method]
    end

    liaison 'release', { id: @pi.item[:id], method: method, quantity: 1 } 

  end

end
