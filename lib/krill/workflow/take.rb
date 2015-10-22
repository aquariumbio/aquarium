module Krill

  class Op

    # Take all selected items.
    # @return [Op] Returns itself. Can be chained.
    def take &block

      ispecs = get_ispec_io

      items = []
      collections = []

      ispecs.each do |ispec|

        ispec[:instantiation].each do |instance|

          if ispec[:is_part]

            c = take_collection_containing instance
            collections << c if c

          elsif instance[:item]

            items << (take_item_in instance)

          elsif instance[:collection] && instance[:row] && instance[:col]
            
            collections << (take_collection_for instance)

          elsif instance[:sample] && instance[:container] && ispec[:is_vector]

            item_array = take_items_for instance
            if !item_array.member? nil
              items = items + item_array 
            end

          elsif instance[:sample] && instance[:container] && !ispec[:is_vector]

            i = take_item_for instance
            if i
              items << i 
            end

          elsif instance[:sample] && ! instance[:container]
            error instance, "Could not take an item associated with #{instance[:sample]} because no container was specified."

          elsif instance[:sample_type] && instance[:container]
            error instance, "Unimplemented: take item from sample_type and container ispec."

          elsif instance[:container]

            container_items = ObjectType.find(instance[:container].as_container_id).items

            if container_items.length > 0
              instance[:item] = container_items[0].id
              items << container_items[0]
            else 
              error instance, "Could not find any items whose container type is #{instances[:container]}"
            end

          elsif # any item meets the specification
            error instance, "Unimplemented: take item from empty ispec."
          end
            
        end

      end

      # Todo: Remove duplicates from items and collections

      raise "Ack! nil item requested: #{items}" if items.member? nil
      raise "Ack! nil collection requested: #{collections}" if collections.member? nil      

      @protocol.take (items+collections), interactive: true,  method: "boxes", &block

      self

    end

    private

    def take_collection_containing instance

      ot = ObjectType.find(instance[:container].as_container_id)

      unless ot.handler == "collection"
        raise "in #{instance}, is_part = true but container #{instance[:container]} is not a collection" 
      end

      unless instance[:sample]
        raise "no sample specified in #{instance}"
      end

      s = Sample.find(instance[:sample].as_sample_id)

      unless s
        raise "sample '#{s}' not found"
      end

      collections = Collection.containing s, ot

      puts "found collections = #{collections} with length = '#{collections.length}'"

      if collections.length > 0
        c = collections.first
        instance[:collection_id] = c.id
        p = c.position s
        if p
          instance[:row] = p[:row] 
          instance[:column] = p[:column]
        else
          error instance, "Could not determine row and column for #{instance[:sample]} in collection #{c.id}"
        end
        puts "found #{s.id} in collection #{c.id}"
        c
      else
        error instance, "Could not find collection of type #{ot.name} containing sample '#{instance[:sample]}'"
        nil
      end

    end

    def take_collection_for instance
      collections << Collection.find(instance[:collection])
    end

    def take_item_in instance

      item = Item.find_by_id(instance[:item_id])

      if item
        instance[:item_id] = item.id
      end

      return item

    end # take_item_in  

    def take_item_for instance

      item = first_item instance

      if item
        instance[:item_id] = item.id
      end

      return item

    end # take_item_for

    def take_items_for instance
      
      item_array = first_item_array instance

      if item_array.member? nil
        instance[:item_ids] = []
      else
        instance[:item_ids] = item_array.collect { |i| i.id }
      end

      return item_array

    end # take_items_for 

  end

end