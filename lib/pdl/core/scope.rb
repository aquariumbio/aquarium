class Scope 

  attr_reader :stack;

  def initialize(opts={})
    o = {
      base: {}
    }.merge opts
    @stack = [o[:base]]
  end

  def set_stack stack
    @stack = stack
  end

  def set symbol, value
    @stack.last[symbol] = value
  end

  def set_base_symbol symbol, value
    @stack.first[symbol] = value
  end

  def push 
    @stack.push( {} )
  end

  def pop
    @stack.pop
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
    str % collapse
  end

  def symbol_subs
    syms = {}
    collapse.each do |k,v|
      syms[k] = "(get :#{k})"
    end
    syms
  end

  def evaluate str
    expr = str % symbol_subs 
    begin
      result = eval(expr)
    rescue Exception => e
      raise "Could not evaluate #{expr}: " + e.message
    end
    result
  end

  def to_s
    s = ""
    indent = "  "
    @stack.reverse.each do |table| 
      table.each do |key,value|
        s += indent + key.to_s + ': '
        if value.kind_of?(Array)
          s += "\n"
          value.each do |el|
            s += indent + indent + el.to_s + "\n"
          end
        else
          s += value.to_s + "\n"
        end
      end
      indent += "  "
    end
    return s
  end

end
