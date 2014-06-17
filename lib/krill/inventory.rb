module Krill

  class ProtocolHandler

    def take items

      puts job

      items.each do |i|
        t = Take.new( { job_id: job, item_id: i.id } ).save
      end

    end

    def release items

      items.each do |i|
        i.takes.each do |t|
          t.destroy
        end
      end

    end

    def display_take items

      takes = items.collect do |i|
        { take: i.features }
      end

      display(
        [ { title: "Gather the Following Item(s)" } ].concat takes
      )

      take items

    end

    def display_release items

      rels = items.collect do |i|
        { take: i.features }
      end

      display(
        [ { title: "Return the Following Item(s)" } ].concat rels
      )

      release items

    end

    def produce spec

      i = Item.new

      olist = find( :object_type, { name: spec[:object_type] } )
      raise "Could not find object type named '#{spec[:object_type]}'." unless olist.length > 0
      i.object_type_id = olist[0].id

      if spec[:sample]

        slist = find( :sample, { name: spec[:sample], sample_type: { name: spec[:sample_type] } } )
        raise "Could not find sample named '#{spec[:sample]}' of type '#{spec[:sample_type]}'." unless slist.length > 0
        i.sample_id = slist[0].id
        i.location = olist[0].location_wizard({project: slist[0].project})

      else

        i.location = olist[0].location_wizard

      end

      i.quantity = 1
      i.save

      take([i])

      return i

    end

  end

end
