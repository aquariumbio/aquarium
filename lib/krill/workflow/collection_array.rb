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

    def nonempty?
      self.sample >= 0
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
        if slot.nonempty?
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
              if slot.ingredients[k]
                row << slot.ingredients[k][:id]
                row << { content: slot.ingredients[k][:volume], check: true }
              else
                row << '?' << '?'
              end
            end
          end
          rows << row          
        end
      end

      [ legend ] + rows

    end

  end

  class Op

    def new_collections

      ispecs = get_ispec_io

      raise "No alternatives in ispec" unless ispecs.first[:alternatives].length > 0
      raise "No container in first ispec alternative" unless ispecs.first[:alternatives].first[:container]

      id = ispecs.first[:alternatives].first[:container].split(":").first.to_i
      ot = ObjectType.find(id)

      raise "Container #{ot.name} is not a collection" unless ot.handler == "collection"

      d = ot.default_dimensions
      capacity = d[0]*d[1]

      collections = CollectionArray.new
      n = (ispecs.collect { |i| i[:instantiation].length }).inject{|sum,x| sum + x }
      (n / capacity.to_f).ceil.times do 
        collections << Collection.new_collection(ot.name, d[0], d[1])
      end

      collections

    end

    def associate index, slot    

      ispecs = get_ispec_io

      raise "Indeterminant ispec." unless ispecs.length == 1
      raise "Index out of range." unless index < ispecs[0][:instantiation].length
      raise "No sample instantiated in ispec" unless ispecs[0][:instantiation][index][:sample]
      ispecs[0][:instantiation][index][:collection] = slot.collection.id
      ispecs[0][:instantiation][index][:row] = slot.row
      ispecs[0][:instantiation][index][:col] = slot.col
      slot.sample = ispecs[0][:instantiation][index][:sample]

    end

  end

end
