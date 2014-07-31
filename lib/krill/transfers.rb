module Krill

  module Base

    def load_samples headings, ingredients, collections # needs a better name

      if block_given?
        user_shows = ShowBlock.new.run(&Proc.new) 
      else
        user_shows = []
      end

      raise "Empty collection list" unless collections.length > 0

      heading = [ [ "#{collections[0].object_type.name}", "Location" ] + headings ]
      i = 0

      collections.each do |col|

        tab = []
        m = col.matrix

        (0..m.length-1).each do |r|
          (0..m[r].length-1).each do |c|
            if i < ingredients[0].length
              if m.length == 1
                loc = "#{c+1}"
              else
                loc = "#{r+1},#{c+1}"
              end
              tab.push( [ col.id, loc ] + ingredients.collect { |ing| { content: ing[i].id, check: true } } )
            end
            i += 1
          end
        end

        show {
          title "Load #{col.object_type.name} #{col.id}"
          table heading + tab
          raw user_shows
        }

      end

    end # load_samples


    def transfer sources, destinations, options={}

      # go through each well of the sources and transfer it to the next empty well of
      # destinations. Every time a source or destination is used up, advance to 
      # another step.    

      opts = { skip_non_empty: true }.merge options

      if block_given?
        user_shows = ShowBlock.new.run(&Proc.new) 
      else
        user_shows = []
      end

      # source and destination indices
      s=0
      d=0

      # matrix indices
      sr,sc = 0,0
      dr,dc = 0,0
      unless destinations[0].matrix[dr][dc] == -1
        dr,dc = destinations[0].next 0, 0, skip_non_empty:true
      end

      routing = []

      while sr != nil

        # add to routing table
        routing.push({from:[sr,sc],to:[dr,dc]})

        # increase sr,sc,dr,dc
        sr,sc =      sources[s].next sr, sc, skip_non_empty: false
        dr,dc = destinations[d].next dr, dc, skip_non_empty: true

        # if either is nil
        if !sr || !dr

          # Display 
          show {
            title "Transfer from #{sources[s].object_type.name} #{sources[s].id} to #{destinations[d].object_type.name} #{destinations[d].id}"
            transfer sources[s], destinations[d], routing
            raw user_shows
          }

          # Update destination collection
          routing.each do |r|
            destinations[d].set r[:to][0], r[:to][1], Sample.find(sources[s].matrix[r[:from][0]][r[:from][1]])
          end

          destinations[d].save

          # clear routing for next step
          routing = []

          # update source indices
          if !sr
            s += 1
            return unless s < sources.length
            sr,sc = 0,0
          end

          # update destination indices
          if !dc
            d += 1
            return unless d < destinations.length
            dr,dc = 0,0
            unless destinations[d].matrix[dr][dc] == -1
              dr,dc = destinations[d].next 0, 0, skip_non_empty: true
            end
          end

        end

      end

      return

    end # transfer

  end

end

