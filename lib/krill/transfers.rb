# frozen_string_literal: true

module Krill

  module Base

    # Displays a table to the user that describes how to load a number of samples into a collection.
    #
    # @param headings [Array<String>] describes how much to transfer of each ingredient
    # @param ingredients [Array<Array<Item>>]  items to be loaded from
    # @param collections [Array<Collections>]  the collections that will be loaded into
    # @yield [block]  {ShowBlock} style block
    # @example shows the user a table that describes how to arrays of templates, forward primers, and reverse primers into a set of stripwell tubes
    #  load_samples(
    #    [ "Template, 1 µL", "Forward Primer, 2.5 µL", "Reverse Primer, 2.5 µL" ],
    #    [  templates,        forward_primers,          reverse_primers         ],
    #    stripwells ) {
    #      note "Load templates first, then forward primers, then reverse primers."
    #      warning "Use a fresh pipette tip for each transfer."
    #    }
    def load_samples(headings, ingredients, collections) # needs a better name

      user_shows = if block_given?
                     ShowBlock.new.run(&Proc.new)
                   else
                     []
                   end

      raise 'Empty collection list' if collections.empty?

      heading = [[collections[0].object_type.name.to_s, 'Location'] + headings]
      i = 0

      collections.each do |col|

        tab = []
        m = col.matrix

        (0..m.length - 1).each do |r|
          (0..m[r].length - 1).each do |c|
            if i < ingredients[0].length
              loc = if m.length == 1
                      (c + 1).to_s
                    else
                      "#{r + 1},#{c + 1}"
                    end
              tab.push([col.id, loc] + ingredients.collect { |ing| { content: (ing[i].is_a? Item) ? ing[i].id : ing[i], check: true } })
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

    # Displays a set of pages using the transfer method from show
    # that describe to the user how to transfer individual parts of some
    # quantity of source wells to some quantity of destination wells.
    # Routing is computed automatically.
    #
    # @param sources [Array<Collection>]  collections that will be transfered from
    # @param destinations [Array<Collection>]  collections that will recieve new parts
    #                             from the source collections
    # @yield [block]  {ShowBlock} style block
    # @example transfer all the wells in a set of stripwell tubes into the non-empty lanes of a set of gels
    #    transfer( stripwells, gels ) {
    #      note "Use a 100 µL pipetter to transfer 10 µL from the PCR results to the gel as indicated."
    #    }
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

      until sr.nil?

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
        next if dc

        d += 1
        return unless d < destinations.length

        dr = 0
        dc = 0
        dr, dc = destinations[d].next 0, 0, skip_non_empty: true unless destinations[d].matrix[dr][dc] == -1

      end

      nil

    end # transfer

    # Opposite of load_samples, displays how to transfer sample
    # from each part of a collection into distinct new Items.
    #
    # @param col [Collection]  the collection to distribute from
    # @param object_type_name [String]  the object type of the new items that will be made
    # @yield [block]  {ShowBlock} style block
    # @return [Array<Item>]  new items that are made from the samples in the collection
    # @example  suppose you had a gel with ladder in lanes (1,1) and (2,1) and you wanted to make gel fragments from the lanes.
    #    slices = distribute( gel, "Gel Slice", except: [ [0,0], [1,0] ], interactive: true ) {
    #      title "Cut gel slices and place them in new 1.5 mL tubes"
    #      note "Label the tubes with the id shown"
    #    }
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
