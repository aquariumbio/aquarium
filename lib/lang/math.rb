module Lang

  class Scope

    # Numerical functions
    math_function :log, :log2, :log10, :cos, :sin, :tan, :acos, :asin, :atan, :sqrt

    def floor x
      if x.class == Fixnum
        x
      elsif x.class == Float
        x.floor
      else
        raise "Attempted to take floor of a #{x.class}."
      end
    end

    def ceil x
      if x.class == Fixnum
        x
      elsif x.class == Float
        x.ceil
      else
        raise "Attempted to take floor of a #{x.class}."
      end
    end

    def min x, y
      if (x.class == Fixnum || x.class == Float) || (y.class == Fixnum || y.class == Float)
        if x < y
          x
        else
          y
        end
      else
        raise "Attempted to take min of a #{x.class} and a #{y.class}."
      end
    end

    def max x, y
      if (x.class == Fixnum || x.class == Float) || (y.class == Fixnum || y.class == Float)
        if x > y
          x
        else
          y
        end
      else
        raise "Attempted to take max of a #{x.class} and a #{y.class}."
      end
    end

    def atan2 y, x
      if (x.class == Fixnum || x.class == Float) || (y.class == Fixnum || y.class == Float)
        Math.atan2(y, x)
      else
        raise "Attempted to take atan2 of a #{y.class} and a #{x.class}."
      end
    end

    def mod x, y
      if x.class == Fixnum || y.class == Float
        x % y
      else
        raise "Attempted to modulo non-integers."
      end
    end

  end

end
