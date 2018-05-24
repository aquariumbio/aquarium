module Lang

  class Scope

    attr_reader :stack;

    def initialize(opts = {})
      o = {
        base: {}
      }.merge opts
      @stack = [o[:base]]
    end

    def set_stack stack
      @stack = stack
    end

    def set_new symbol, value
      @stack.last[symbol] = value
    end

    def set symbol, value

      # Semantics: if symbol is already set, then reset it to value
      #            if symbol is not set, then add it to the top of the stack and set it to the specified value

      i = @stack.length - 1

      while @stack[i][symbol] == nil && i >= 0
        i -= 1
      end

      if @stack[i][symbol]
        @stack[i][symbol] = value
      else
        @stack.last[symbol] = value
      end

    end

    def set_base_symbol symbol, value
      @stack.first[symbol] = value
    end

    def set_complex lhs, rhs, new ################################################################################

      temp_lhs = lhs.gsub /%{([a-zA-Z][a-zA-Z_0-9]*)}/, '\1'
      temp_parser = Plankton::Parser.new("n/a", temp_lhs)
      parts = temp_parser.get_lhs_parts

      # get the current value of the variable
      v = get(parts[:var])
      expr = "v#{parts[:accessor]} = #{rhs}" % symbol_subs
      eval(expr)

      if new
        set_new(parts[:var].to_sym, v)
      else
        set(parts[:var].to_sym, v)
      end

    end # set_complex #############################################################################################

    def push
      @stack.push({})
    end

    def pop
      @stack.pop
    end

    def defined_in_top sym
      @stack.last[sym] != nil
    end

    def get symbol
      i = @stack.length - 1
      while @stack[i][symbol] == nil && i >= 0
        i -= 1
      end
      return @stack[i][symbol]
    end

    def collapse
      result = {}
      @stack.reverse.each do |h|
        result = h.merge result
      end
      return result
    end

    def substitute str
      begin
        str % collapse
      rescue Exception => e
        raise "Unkown symbol in text. " + e.message.sub('key', '%')
      end
    end

    def symbol_subs
      syms = {}
      collapse.each do |k, v|
        syms[k] = "(get :#{k})"
      end
      syms
    end

    def evaluate str
      begin
        expr = str % symbol_subs
      rescue Exception => e
        raise "Unknown symbol in expression. " + e.message.sub('key', '%')
      end
      # puts "Evaluated #{str} and got #{expr}"
      begin
        result = eval(expr)
      rescue Exception => e
        raise "Could not evaluate #{str} => #{expr}. " + e.message
      end
      result
    end

    def to_s
      s = ""
      indent = "  "
      @stack.reverse.each do |table|
        table.each do |key, value|
          s += indent + key.to_s + ': '
          if value.kind_of?(Array)
            s += "\n"
            value.each do |el|
              s += indent + indent + el.to_s + "<br />"
            end
          else
            s += value.to_s + "<br />"
          end
        end
        indent += "&nbsp;"
      end
      return s
    end

  end

end
