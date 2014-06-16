module Krill

  class ProtocolHandler

    def take items

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

  end

end
