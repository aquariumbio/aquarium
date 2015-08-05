module Krill

  class Op

    def sample ispec

      if ispec[:sample]
        if ispec[:sample].class == String
          Sample.find(ispec[:sample].split(':')[0])
        else
          Sample.find(ispec[:sample])
        end
      else
        nil
      end

    end

    def container ispec

      if ispec[:container]
        if ispec[:container].class == String
          ObjectType.find(ispec[:container].split(':')[0])
        else
          ObjectType.find(ispec[:container])
        end
      else
        nil
      end

    end    

    def first_item ispec

      i = (sample ispec).items.select { |i| i.object_type_id == (container ispec).id }
      if i.length > 0 
        i.first
      else
        nil
      end

    end

    def error ispec, msg
      ispec[:errors] ||= []
      ispec[:errors] << msg
    end

    #######################################################################################
    def take &block

      ispecs = get_ispec_io

      items = []
      collections = []

      ispecs.each do |ispec|

        ispec[:instantiation].each do |instance|

          if instance[:is_part]

            error instance, "Unimplemented: take the collection containing a particular ispec"

          elsif instance[:item]

            items << Item.find(instance[:item])

          elsif instance[:sample] && instance[:container]

            if @query

              error instance, "Unimplemented: take item from sample ispec with method query."

            else

              i = first_item instance
              if i
                instance[:item] = i.id
                items << i
              else
                error instance, "Could not find an item associated with #{instance[:sample]}."
              end

            end

          elsif instance[:sample] && ! instance[:container]
            error instance, "Could not take an item associated with #{instance[:sample]} because no container was specified."
          elsif instance[:sample_type] 
            error instance, "Unimplemented: take item from sample_type and container ispec."
          elsif instance[:container]
            error instance, "Unimplemented: take item container ispec."
          elsif # any item meets the specification
            error instance, "Unimplemented: take item from empty ispec."
          end
            
        end

      end

      @protocol.take (items+collections), interactive: true,  method: "boxes", &block

      self

    end

    #######################################################################################
    def release &block

      ispecs = get_ispec_io

      items = []

      ispecs.each do |ispec|

        ispec[:instantiation].each do |instance|

          if instance[:item]
            items << Item.find(instance[:item])
          end

        end

      end

      @protocol.release items, interactive: true,  method: "boxes", &block      

      self

    end

    #######################################################################################
    def produce &block

      ispecs = get_ispec_io

      ispecs.each do |ispec|

        ispec[:instantiation].each do |instance| 

          if instance[:sample] && instance[:container]
            s = sample instance
            o = container instance
            i = @protocol.produce( @protocol.new_sample s.name, of: s.sample_type.name, as: o.name )
            instance[:item] = i.id
          elsif instance[:container]
            o = container instance
            if o.handler == "collection"
              d = o.default_dimensions
              i = @protocol.produce( @protocol.new_collection o.name, d[0], d[1] )
            else
              i = @protocol.produce( @protocol.new_object o.name )
            end
            instance[:item] = i.id
          else
            error instance, "Unimplemented: produce item from ispec without sample and/or container."
          end

        end

      end

      self

    end    

  end

end
