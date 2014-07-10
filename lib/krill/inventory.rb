module Krill

  class Box

    def initialize
      @slots = Array.new
      (0..80).each do |i|
        @slots[i] = { content: i, class: 'td-empty-slot' }
      end
    end

    def highlight index, id
      @slots[index] = { content: id, class: 'td-filled-slot', check: true }
    end

    def table
      t = Array.new(9)
      (0..8).each do |row|
        t[row] = @slots[9*row,9]
      end
      t
    end

  end


  module Base

    # Warning: Adding classes and modules to this module will likely result in
    # an infinite loop when Base is inserted into the user's code ancestry. Put
    # them in the top level Krill module instead (as in Box) above.

    def boxes_for items

      boxes = {}
      extras = []

      r = Regexp.new ( '(M20|M80|SF[0-9]*)\.[0-9]+\.[0-9]+\.[0-9]+' )

      items.each do |i|

        if r.match(i.location)

          freezer,hotel,box,slot = i.location.split('.')
          slot = slot.to_i
          name = "#{freezer}.#{hotel}.#{box}"

          boxes[name] = Box.new unless boxes[name]
          boxes[name].highlight slot, i.id

        else

          extras.push i

        end

      end

      [ boxes, extras ]

    end


    def box_interactive items, box_note, extra_title, user_shows

      boxes, extras = boxes_for items

      boxes.each do |name,box|
        show {
          title name
          note box_note
          table box.table
          raw user_shows
        }
      end

      if extras.length > 0
        takes = extras.collect { |i| i.features }
        show {
          title extra_title
          takes.each do |t|
            item t
          end
          raw user_shows
        }
      end

    end


    def take items, args={}

      if block_given?
        user_shows = ShowBlock.new.run(&Proc.new) 
      else
        user_shows = []
      end

      options = {
        interactive: false,
        method: "list"
      }.merge args

      if options[:interactive]

        case options[:method]

        when "boxes"

          box_interactive items, "Collect Item(s)", "Gather the Following Additional Item(s)", user_shows

        else

          takes = items.collect { |i| i.features }
          show {
            title "Gather the Following Item(s)"
            takes.each do |t|
              item t
            end
            raw user_shows
          }
        end

      end

      items.each do |i|
        t = Take.new( { job_id: jid, item_id: i.id } ).save
      end

    end


    def release items, args={}

      if block_given?
        user_shows = ShowBlock.new.run(&Proc.new) 
      else
        user_shows = []
      end

      options = {
        interactive: false
      }.merge args

      if options[:interactive]

        case options[:method]

        when "boxes"

          box_interactive items, "Return Item(s)", "Return the Following Additional Item(s)", user_shows
          
        else

          rels = items.collect { |i| i.features }
          show { 
            title "Return the Following Item(s)"
            rels.each do |r|
              item r
            end
            raw user_shows
          }
        end

      end

      items.each do |i|
        i.takes.each do |t|
          t.destroy
        end
      end

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

      if spec[:data]

        i.data = spec[:data].to_json

      end

      i.quantity = 1
      i.save

      take([i])

      return i

    end

  end

end
