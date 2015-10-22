module Krill

  class Op

    # Release all selected inventory.
    # @return [Op] Returns itself. Can be chained.
    def release &block

      ispecs = get_ispec_io

      items = []

      ispecs.each do |ispec|

        if ispec[:is_part]

          ispec[:instantiation].each do |instance|

            if instance[:collection]
              c = Item.find(instance[:collection]) 
              items << c unless items.member? c
            end

          end

        else

          ispec[:instantiation].each do |instance|

            if instance[:item]
              if instance[:item].class == Array
                items = items + Item.find(instance[:item])
              else
                items << Item.find(instance[:item])
              end
            end

          end

        end

      end

      @protocol.release items, interactive: true,  method: "boxes", &block      

      self

    end

  end

end