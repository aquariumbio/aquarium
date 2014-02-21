module Lang

  class Scope

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
