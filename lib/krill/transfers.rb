module Krill

  module Base

    def load_samples(headings, ingredients, collections) # needs a better name

      user_shows = if block_given?
        ShowBlock.new.run(&Proc.new)
      else
        []
                   end

      raise 'Empty collection list' unless !collections.empty?

      heading = [[(collections[0].object_type.name).to_s, 'Location'] + headings]
      i = 0

      collections.each do |col|

        tab = []
        m = col.matrix

        (0..m.length - 1).each do |r|
          (0..m[r].length - 1).each do |c|
            if i < ingredients[0].length
              loc = if m.length == 1
                "#{c + 1}"
              else
                "#{r + 1},#{c + 1}"
                    end
              tab.push([col.id, loc] + ingredients.collect { |ing| { content: ing[i].is_a? Item ? ing[i].id : ing[i], check: true } })
            end
            i += 1
          end
        end

        show do
          title "Load #{col.object_type.name} #{col.id}"
          table heading + tab
          raw user_shows
        end

      end

    end # load_samples

    def transfer(sources, destinations, options = {})

      # go through each well of the sources and transfer it to the next empty well of
      # destinations. Every time a source or destination is used up, advance to
      # another step.

      opts = { skip_non_empty: true }.merge options

      user_shows = if block_given?
        ShowBlock.new.run(&Proc.new)
      else
        []
                   end

      # source and destination indices
      s = 0
      d = 0

      # matrix indices
      sr = 0
      sc = 0
      dr = 0
      dc = 0
      dr, dc = destinations[0].next 0, 0, skip_non_empty: true unless destinations[0].matrix[dr][dc] == -1

      routing = []

      while !sr.nil?

        # add to routing table
        routing.push(from: [sr, sc], to: [dr, dc])

        # increase sr,sc,dr,dc
        sr, sc = sources[s].next sr, sc, skip_non_empty: false
        dr, dc = destinations[d].next dr, dc, skip_non_empty: true

        # if either is nil or if the source well is empty
        next unless !sr || !dr || sources[s].matrix[sr][sc] == -1

        # display
        show do
          title "Transfer from #{sources[s].object_type.name} #{sources[s].id} to #{destinations[d].object_type.name} #{destinations[d].id}"
          transfer sources[s], destinations[d], routing
          raw user_shows
        end

        # update destination collection
        routing.each do |r|
          destinations[d].set r[:to][0], r[:to][1], Sample.find(sources[s].matrix[r[:from][0]][r[:from][1]])
        end

        destinations[d].save

        # clear routing for next step
        routing = []

        # BUGFIX by Yaoyu Yang
        # return if sources[s].matrix[sr][sc] == -1
        #
        if sr && sources[s].matrix[sr][sc] == -1
          s += 1
          return unless s < sources.length
          sr = 0
            sc = 0
        end
        # END BUGFIX

        # update source indices
        unless sr
          s += 1
          return unless s < sources.length
          sr = 0
            sc = 0
        end

        # update destination indices
        unless dc
          d += 1
          return unless d < destinations.length
          dr = 0
            dc = 0
          dr, dc = destinations[d].next 0, 0, skip_non_empty: true unless destinations[d].matrix[dr][dc] == -1
        end


      end

      nil

    end # transfer

    def distribute(col, object_type_name, options = {})

      opts = { except: [], interactive: false }.merge options

      object_type = ObjectType.find_by_name(object_type_name)
      raise "Could not find object type #{object_type_name} in distribute" unless object_type

      user_shows = if block_given?
        ShowBlock.new.run(&Proc.new)
      else
        []
                   end

      m = col.matrix
      items = []
      routes = []

      (0..m.length - 1).each do |i|
        (0..m[i].length - 1).each do |j|
          next unless m[i][j] > 0 && !(opts[:except].include? [i, j])
          s = find(:sample, id: m[i][j])[0]
          item = Item.make({ quantity: 1, inuse: 0 }, sample: s, object_type: object_type)
          items.push item
          routes.push from: [i, j], to: item
        end
      end

      if opts[:interactive]
        show do
          table [
            ['Row', 'Column', 'New ' + object_type_name + ' id']
          ].concat(routes.collect { |r| [r[:from][0] + 1, r[:from][1] + 1, r[:to].id] })
          raw user_shows
        end
      end

      items

    end # distribute

  end

end
