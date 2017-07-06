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

    def new_object name
      Item.new_object name
    end

    def new_sample name, spec
      s = Sample.find_by_name(name)
      ot = ObjectType.find_by_name(spec[:as])
      raise "Unknown sample #{name}" unless s
      raise "Unknown container #{spec[:as]}" unless ot
      Item.make( { quantity: 1, inuse: 0 }, sample: s, object_type: ot )
    end

    def new_collection name, r, c
      Collection.new_collection name, r, c
    end

    def collection_from id
      Collection.find id
    end

    def spread samples, name, options={}
      opts = { reverse: false }.merge(options)
      Collection.spread samples, name, opts
    end

    # sorts items alphanumerically by freezer, hotel, box, then slot
    def sort_by_location items
      return [] if items.empty?
      locations = items.map { |item| item.location.split(".") }
      sorted_locations = locations.sort { |loc1, loc2| 
                                                comp = loc1[0] <=> loc2[0]
                                                comp = comp.zero? ? loc1[1].to_i <=> loc2[1].to_i : comp
                                                comp = comp.zero? ? loc1[2].to_i <=> loc2[2].to_i : comp
                                                comp.zero? ? loc1[3].to_i <=> loc2[3].to_i : comp }
      loc_strings = sorted_locations.map { |loc| "#{loc[0]}.#{loc[1]}.#{loc[2]}.#{loc[3]}" }
      items.sort_by! { |item| loc_strings.index(item.location) }
    end # sort_by_location

    def boxes_for items

      boxes = {}
      loc_matched_items = []
      extras = []

      r = Regexp.new ( '(M20|M80|SF[0-9]*)\.[0-9]+\.[0-9]+\.[0-9]+' )

      loc_matched_items = items.select { |i| r.match(i.location) }
      extras = items - loc_matched_items

      # make boxes for the items with valid box locations, sorted by location
      (sort_by_location loc_matched_items).each do |i|

          freezer,hotel,box,slot = i.location.split('.')
          slot = slot.to_i
          name = "#{freezer}.#{hotel}.#{box}"

          boxes[name] = Box.new unless boxes[name]
          boxes[name].highlight slot, i.id

      end

      [ boxes, extras ]

    end

    def box_interactive items, method, user_shows

      boxes, extras = boxes_for items

      if method == :take
        show_title = "Take from "
        box_note = "Collect Item(s)"
        extra_title = "Gather the Following Additional Item(s)"
      elsif method == :return
        show_title = "Return to "
        box_note = "Return Item(s)"
        extra_title = "Return the Following Additional Item(s)"
      else
        show_title = ""
        box_note = "" 
        extra_title = ""
      end

      if boxes.length > 0
        show {
          title "Boxes Required"
          note "You will need the following boxes from the freezer(s)"
          table (boxes.keys.collect { |b| { content: b, check: true }}).each_slice(6).to_a
        }
      end

      boxes.each do |name,box|
        show {
          title show_title + name
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

          box_interactive items, :take, user_shows

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
        Take.new( { job_id: jid, item_id: i.id } ).save
        Touch.new( { job_id: jid, item_id: i.id } ).save
      end

      items

    end

    def touch item
      Touch.new( { job_id: jid, item_id: item.id } ).save
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

          box_interactive items, :return, user_shows
          
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
        takes = Take.where(item_id: i.id).destroy_all
      end

      items

    end

    def produce items
      if items.class == Array
        take items
      else
        (take [items])[0]
      end

    end

  end

end
