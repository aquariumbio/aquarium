module Krill

  class Slot

    attr_reader :row, :col, :collection
    attr_accessor :ingredients

    def initialize col, r, c
      @collection = col
      @row = r
      @col = c
      @ingredients = {}
    end

    def sample
      @collection.matrix[@row][@col]
    end

    def sample= s
      @collection.set @row, @col, s
    end

    def empty?
      self.sample < 0
    end

  end

  class CollectionArray < Array

    def initialize
      @slot_list = []
      super
    end

    def slots col=nil

      if col

        return unless col >= 0 && col < self.length

        collection = self[col]
        d = collection.dimensions
        index = col * d[0] * d[1]

        d[0].times do |r|
          d[1].times do |c|
            @slot_list[index] ||= Slot.new(collection, r, c)
            yield index, @slot_list[index]
            index += 1
          end
        end

      else # loop through all collections

        index = 0

        self.each do |collection|
          d = collection.dimensions
          d[0].times do |r|
            d[1].times do |c|
              @slot_list[index] ||= Slot.new(collection, r, c)
              yield index, @slot_list[index]
              index += 1
            end
          end
        end

      end

    end

    def slot c, row, col
      
      return nil unless c < self.length
      d = self.first.dimensions
      return nil if row>d[0] || col>d[1]
      n = d[0]*d[1]
      index = c*n + row*d[1] + col
      @slot_list[index] ||= Slot.new(self[c], row, col)
      @slot_list[index]

    end

    def table c, specs

      # make legend
      legend = []
      specs.each do |k,v|
        case k
        when :id, :row, :col
          legend << v
        else
          legend << v + " id" << v + " volume"
        end
      end

      # make rows
      rows = []
      slots c do |index,slot|
        row = []
        specs.each do |k,v|
          case k
          when :id
            row << slot.collection.id
          when :row
            row << slot.row
          when :col
            row << slot.col
          else
            row << slot.ingredients[k][:id]
            row << { content: slot.ingredients[k][:vol], check: true }
          end
        end
        rows << row
      end

      [ [ legend ] ] + rows

    end

  end

end
