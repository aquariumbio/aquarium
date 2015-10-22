module Krill

  class Op

    # Produce all selected inventory.
    # @return [Op] Can be chained.
    def produce &block

      ispecs = get_ispec_io

      ispecs.each do |ispec|

        if ispec[:is_part]

          collections = []

          ispec[:instantiation].each do |instance| 
            if instance[:collection]
              c = Item.find(instance[:collection]) 
              collections << c unless collections.member? c
            end
          end

          @protocol.produce collections

        else

          ispec[:instantiation].each do |instance| 

            if instance[:sample] && instance[:container]

              if instance[:sample].class == Array
                ss = sample instance
                o = container instance
                instance[:item] = []
                ss.each do |s|
                  i = @protocol.produce( @protocol.new_sample s.name, of: s.sample_type.name, as: o.name )
                  instance[:item] << i.id
                end                
              else
                s = sample instance
                o = container instance
                i = @protocol.produce( @protocol.new_sample s.name, of: s.sample_type.name, as: o.name )
                instance[:item] = i.id
              end

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

          end # instance.each

        end # if/else

      end # ispec.each

      self

    end # produce

  end

end