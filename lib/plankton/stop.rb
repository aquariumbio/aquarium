module Plankton

  class Parser

    def stop

      @tok.eat_a 'stop'

      lines = {}
      lines[:startline] = @tok.line
      lines[:endline] = @tok.line
      push StopInstruction.new lines
       
    end

  end

end
