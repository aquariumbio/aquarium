module Lang

  class Scope

    def merge g, h

      if g.class == Hash && h.class == Hash
        g.merge h
      else
        raise "Attempted to merge a #{g.class} and a #{h.class}."
      end

    end

    def keys h

      if h.class == Hash
        h.keys
      else
        raise "Attempted to get keys of a #{h.class}."
      end

    end

    def delete h, k

      if h.class == Hash && k.class == Symbol
        g = h.dup
        g.delete k
        g
      else
        raise "Attempted to delete #{k.class} from a #{h.class}."
      end

    end

    def key h, k

      if h.class == Hash && k.class == Symbol
        h.has_key? k
      else
        raise "Attempted to find #{k.class} in a #{h.class}."
      end

    end

  end

end
