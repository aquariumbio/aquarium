# frozen_string_literal: true

require 'strscan'

class String

  def remove_quotes
    self[1..-1][0..-2]
  end

end

module Plankton

  class Parser

    def string_expr

      result = ''

      result += @tok.eat_a_string.remove_quotes

      while @tok.current == '+'
        @tok.eat
        result += string_expr
      end

      result

    end # string_expr

  end

end
