module Krill

  # Instances of Slot represent elements of a [Collection]. The most likley way
  # you will encounter a slot is when iterating over a collection or [CollectionArray].
  #
  # Each slot has a row, column, and sample id, and you can test whether it is empty or nonempty.
  #
  # @example Show the contents of a collection, slot by slot
  #  show do 
  #    collection_array.slots do |slot|
  #      if slow.nonempty?
  #        note "#{slot.collection.id}(#{slot.row},#{slot.col}) = #{slot.sample_id}"
  #       end
  #     end
  #   end
  #
  class Slot

    attr_reader :row, :column, :collection
    attr_accessor :ingredients

    # @private
    def initialize parent, col, r, c
      @parent = parent
      @collection = col
      @row = r
      @column = c
      @ingredients = {}
    end

    def next
      @parent.sucessor self
    end

    # Returns the sample associated with the slot.
    # @warning Use sample_id instead. This method will return the actual {Sample} object in the future.
    # @return [Fixnum]
    def sample
      @collection.matrix[@row][@column]
    end

    # Returns the sample id associated with the slot.
    # @return [Fixnum]    
    def sample_id
      @collection.matrix[@row][@column]
    end

    # Associate the sample id s with the slot
    # @param [Fixnum]
    def sample= s
      @collection.set @row, @column, s
    end

    # Returns true if and only if the slot is empty.
    def empty?
      self.sample < 0
    end

    # Returns true if and only if the slot is not empty.
    def nonempty?
      self.sample >= 0
    end

  end

  class CollectionArray < Array

    def initialize
      @slot_list = []
      super
    end

    def num_slots
      if self.length > 0
        d = self[0].dimensions
        self.length * d[0] * d[1]
      else
        0
      end
    end

    def sucessor slot

      i = @slot_list.index slot

      if i && @slot_list[i+1]
        @slot_list[i+1]
      elsif i && !slot_list[i+1]
        d = slot.collection.dimensions
        c = self.index(slot.collection)
        if slot[:column]+1 < d[1]
          @slot_list[i+1] = Slot.new(self,slot.collection,slot.row,slot.column+1)
        elsif slot[:row]+1 < d[0]
          @slot_list[i+1] = Slot.new(self,slot.collection,slot[:row]+1,0)         
        elsif c+1 < self.length
          @slot_list[i+1] = Slot.new(self,self[c+1],0,0)         
        else
          nil
        end
      end

    end

    def slots col=nil

      if col

        return unless col >= 0 && col < self.length

        collection = self[col]
        d = collection.dimensions
        index = col * d[0] * d[1]

        d[0].times do |r|
          d[1].times do |c|
            @slot_list[index] ||= Slot.new(self,collection, r, c)
            index += 1
          end
        end

      else # loop through all collections

        index = 0

        self.each do |collection|
          d = collection.dimensions
          d[0].times do |r|
            d[1].times do |c|
              @slot_list[index] ||= Slot.new(self,collection, r, c)
              index += 1
            end
          end
        end

      end

      @slot_list

    end

    def slot c, row, col
      
      return nil unless c < self.length
      d = self.first.dimensions
      return nil if row>d[0] || col>d[1]
      n = d[0]*d[1]
      index = c*n + row*d[1] + col
      @slot_list[index] ||= Slot.new(self,self[c], row, col)
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

    def collections

      ispecs = get_ispec_io

      cs = CollectionArray.new

      ispecs.first[:instantiation].each { |ispec|
        if ispec[:collection_id]
          cs << Collection.find(ispec[:collection_id])
        end
      }

      cs

    end

    def new_collections

      ispecs = get_ispec_io

      raise "No alternatives in ispec" unless ispecs.first[:alternatives].length > 0
      raise "No container in first ispec alternative" unless ispecs.first[:alternatives].first[:container]

      id = ispecs.first[:alternatives].first[:container].as_container_id
      ot = ObjectType.find(id)

      raise "Container #{ot.name} is not a collection" unless ot.handler == "collection"

      d = ot.default_dimensions
      capacity = d[0]*d[1]

      collections = CollectionArray.new

      n = (ispecs.collect { |i|
        if i[:is_vector]
          i[:instantiation].collect { |inst|
            inst[:sample].length
          }.inject{|sum,x| sum+x}
        else
          i[:instantiation].length
        end
      }).inject{|sum,x| sum + x }

      (n / capacity.to_f).ceil.times do 
        collections << Collection.new_collection(ot.name, d[0], d[1])
      end

      collections

    end

    def associate index, slot    

      ispecs = get_ispec_io

      raise "More than one ispec selected in associate." unless ispecs.length == 1
      raise "Index out of range." unless index < ispecs[0][:instantiation].length
      raise "No sample instantiated in ispec" unless ispecs[0][:instantiation][index][:sample]

      ispecs[0][:instantiation][index][:collection_id] = slot.collection.id
      ispecs[0][:instantiation][index][:row] = slot.row
      ispecs[0][:instantiation][index][:column] = slot.column
      slot.sample = ispecs[0][:instantiation][index][:sample]

    end

  end

end
