module Krill

  class Op

    # Produce all selected inventory.
    # @return [Op] Can be chained.
    def produce &block

      ispecs = get_ispec_io

      collections = []

      ispecs.each do |ispec|

        ispec[:instantiation].each do |instance| 

          if ispec[:is_part] && !ispec[:is_vector]

            if instance[:collection_id]
              collections << Collection.find(instance[:collection_id])
            end

          elsif ispec[:is_part] && ispec[:is_vector]            

            if instance[:collection_ids]
              collections = collections + Collection.find(instance[:collection_ids])                    
            end

          elsif instance[:sample] && instance[:container] && !ispec[:is_vector]

            produce_sample_from instance

          elsif instance[:sample] && instance[:container] && ispec[:is_vector]

            produce_samples_from instance

          elsif !instance[:sample] && !instance[:sample_type] && instance[:container]

            produce_basic_item_from instance

          else

            error instance, "Unimplemented: produce item from ispec without sample and/or container."

          end

        end # instance.each

      end # ispec.each

      @protocol.produce(collections.uniq) unless collections == []

      self

    end # produce

    private

    def produce_sample_from instance
      s = sample instance
      o = container instance
      i = @protocol.produce( @protocol.new_sample s.name, of: s.sample_type.name, as: o.name )
      instance[:sample_id] = s.id                
      instance[:item_id] = i.id
    end

    def produce_samples_from instance
      sample_array = samples instance 
      o = container instance
      instance[:item_ids] = []
      instance[:sample_ids] = []
      instance[:sample_ids] = sample_array.collect { |s| s.id }
      instance[:item_ids] = sample_array.collect { |s| 
        @protocol.produce( @protocol.new_sample s.name, of: s.sample_type.name, as: o.name ).id
      }      
    end

    def produce_basic_item_from instance
      o = container instance
      if o.handler == "sample_container"
        raise "Cannot produce item only from container #{o} because a sample is required: #{ispec}" 
      end
      if o.handler == "collection"
        d = o.default_dimensions
        i = @protocol.produce( @protocol.new_collection o.name, d[0], d[1] )
      else
        i = @protocol.produce( @protocol.new_object o.name )
      end
      instance[:item_id] = i.id
    end

  end

end
