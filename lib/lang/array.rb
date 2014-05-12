module Lang

  class Scope 

    def length a

      if a.class == Array
        a.length
      else
        raise "Attempted to take length of non-array #{a}"
      end

    end

    def append a, x

      if a.class == Array
        b = a.dup
        b.push x
        b
      else
        raise "Attempted to take append #{x} to non-array #{a}"
      end

    end

    def concat a, b

      if a.class == Array && b.class == Array
        x = a.dup
        y = b.dup
        x.concat y
        x
      else
        raise "Attempted to take concat #{a} and #{b}, which are not both arrays."
      end

    end

    def unique a # returns an array that represents the same set, but with no repeats
      if a.class == Array
        a.uniq
      else
        raise "Attempted to apply uniqie to #{a}, which is not an array."
      end
    end

    def transpose m # transposes the array of array M

      begin
        mt = m.transpose
      rescue Exception => e
        raise "Could not transpose matrix: " + e.to_s
      end

      return mt

    end

  end

end
