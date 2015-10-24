module Krill

  class Op

    # Release all selected inventory.
    # @return [Op] Returns itself. Can be chained.
    def release &block

      ispecs = get_ispec_io

      items = []

      ispecs.each do |ispec|

        ispec[:instantiation].each do |instance|

          if ispec[:is_part] && !ispec[:is_vector]

            items << Collection.find(instance[:collection_id]) 

          elsif ispec[:is_part] && ispec[:is_vector]

            items += Collection.find(instance[:collection_ids]) 

          elsif !ispec[:is_vector]

            items << Item.find(instance[:item_id])

          elsif ispec[:is_vector]

            items += Item.find(instance[:item_ids])

          else

            raise "Cannot release #{instance}"

          end

        end

      end

      @protocol.release items.uniq, interactive: true,  method: "boxes", &block      

      self

    end

  end

end