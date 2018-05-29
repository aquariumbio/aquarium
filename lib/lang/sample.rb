module Lang

  class Scope

    def quantity(obj)

      result = 0

      if obj.class == String

        o = ObjectType.find_by(name: obj)

        result = o.quantity if o

      elsif obj.class == Hash && obj.key?(:sample) && obj.key?(:object)

        puts "QUANTITY: Evaluating quantity(#{obj})"

        s = Sample.find_by(name: obj[:sample])
        o = ObjectType.find_by(name: obj[:object])

        puts "GOT #{s.inspect} and #{o.inspect}"

        result = Item.where('sample_id = ? AND object_type_id = ?', s.id, o.id).length if o && s

      else

        raise "Argument to 'quantity' is not a string, or a hash of the form { object: String, sample: String }"

      end

      result

    end

    def min_quantity(obj)
      o = ObjectType.find_by(name: obj)
      if o
        o.min
      else
        0
      end
    end

    def max_quantity(obj)
      o = ObjectType.find_by(name: obj)
      if o
        o.max
      else
        0
      end
    end

    def info(x)

      if x.class == Hash && x[:id]

        i = Item.find_by(id: x[:id])

        raise "Could not find item #{x[:id]} in argument passed to 'info'" unless i
        raise "Item #{x[:id]} in argument passed to 'info' is not a sample" unless i.sample

        i.sample.attributes.symbolize_keys

      elsif x.class == Integer

        s = Sample.find_by(id: x)

        raise "Could not find sample #{x} in argument passed to 'info'" unless s

        s.attributes.symbolize_keys

      else

        raise "Argument passed to 'info' is not an item"

      end

    end

  end

end
