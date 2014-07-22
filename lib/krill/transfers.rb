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


    def transfer sources, destinations, options

      opts = { skip_non_empty: false }.options

      destinations.each do |dest|

      end      

    end # transfer


  end

end