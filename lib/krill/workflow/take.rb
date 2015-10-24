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

          if ispec[:is_part] && !ispec[:is_vector]

            c = take_collection_containing instance
            collections << c if c

          elsif ispec[:is_part] && ispec[:is_vector]

            c = take_collections_containing instance
            collections = collections + c

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

          elsif instance[:container] && !ispec[:is_vector]

            i = take_item_by_container instance
            items << i if i

          elsif instance[:container] && ispec[:is_vector]

            error instance, "Cannot take a vector of items when only a container is specified: #{instance}"

          elsif # any item meets the specification

            error instance, "Unimplemented: take item from empty ispec #{instance}"

          end
            
        end

      end

      # Todo: Remove duplicates from items and collections

      raise "Ack! nil item requested: #{items}" if items.member? nil
      raise "Ack! nil collection requested: #{collections}" if collections.member? nil      

      @protocol.take (items+collections).uniq, interactive: true,  method: "boxes", &block

      self

    end

    private

    def take_item_by_container instance

      container_items = ObjectType.find(instance[:container].as_container_id).items

      if container_items.length > 0
        instance[:item_id] = container_items[0].id
        container_items[0]
      else 
        error instance, "Could not find any items whose container type is #{instances[:container]}"
        nil
      end

    end

    def collection_helper container, sample

      ot = ObjectType.find(container.as_container_id)
      raise "container '#{container}' is not a collection" unless ot.handler == "collection"

      s = Sample.find(sample.as_sample_id)
      raise "sample '#{sample}' not found" unless s

      collections = Collection.containing s, ot

      if collections.length > 0
        c = collections.first
        [ c, c.position(s) ]
      else
        [ nil, nil ]
      end

    end

    def take_collection_containing instance

      c, p = collection_helper(instance[:container],instance[:sample])

      instance[:collection_id] = c.id if c
      instance.merge! p if p

      error instance, "Could not find collection containing sample '#{instance[:sample]}'" unless c
      error instance, "Could not determine row and column for #{instance[:sample]} in collection" unless !c || p

      c

    end

    def take_collections_containing instance    

      collections = []
      instance[:collection_ids] = []
      instance[:rows] = []
      instance[:columns] = []

      instance[:sample].each do |s|
        c, p = collection_helper(instance[:container],s)
        if c 
          collections << c
          instance[:collection_ids] << c.id
        end
        if p
          instance[:rows] << p[:row] 
          instance[:columns] << p[:column] 
        end
        error instance, "Could not find collection containing sample '#{instance[:sample]}'" unless c
        error instance, "Could not determine row and column for #{instance[:sample]} in collection" unless !c || p
      end

      collections

    end

    def take_collection_for instance
      Collection.find(instance[:collection])
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