module Lang

  class Scope

    def quantity obj

      result = 0

      if obj.class == String

        o = ObjectType.find_by_name(obj)

        if o
          result = o.quantity
        end

      elsif obj.class == Hash && obj.has_key?(:sample) && obj.has_key?(:object)

        puts "QUANTITY: Evaluating quantity(#{obj})"

        s = Sample.find_by_name(obj[:sample])
        o = ObjectType.find_by_name(obj[:object])

        puts "GOT #{s.inspect} and #{o.inspect}"

        if o && s
          result = Item.where("sample_id = ? AND object_type_id = ?",s.id, o.id).length
        end

      else

        raise "Argument to 'quantity' is not a string, or a hash of the form { object: String, sample: String }"

      end

      result
 
    end

    def min_quantity obj
      o = ObjectType.find_by_name(obj)
      if o
        o.min
      else
        0
      end
    end

    def max_quantity obj
      o = ObjectType.find_by_name(obj)
      if o
        o.max
      else
        0
      end
    end

    def info pdl_item

      if pdl_item.class == Hash && pdl_item[:id]
        i = Item.find_by_id(pdl_item[:id])
        if !i
          raise "Could not find item #{pdl_item[:id]} in argument passed to 'info'"
        end
        if !i.sample
          raise "Item #{pdl_item[:id]} in argument passed to 'info' is not a sample"
        end
        return i.sample.attributes.symbolize_keys
      else
        raise "Argument passed to 'info' is not an item"
      end

    end

  end

end
