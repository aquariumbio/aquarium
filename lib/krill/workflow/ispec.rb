module Krill

  # This module is used to extend hashes that represent inventory specifications in operations. 
  module ISpec

    # A list of error messages, if any
    def errors
      self[:errors]
    end

    # Returns true if the ispec refers to a vector of samples, items, parts, or containers
    def is_vector
      self[:is_vector]
    end

    # Associate a sample with an ISpec
    # @return [ISpec] The inventory specification
    def associate_sample sample
      raise "Cannot associate a single sample with a vector based inventory specification." if is_vector
      self[:sample_id] = sample_id
      self[:sample] = "#{sample.id}: #{sample.name}"
      @sample = sample
      self
    end

    # Associate a vector of samples with a vector based ISpec
    # @return [ISpec] The inventory specification    
    def associate_samples samples
      raise "Cannot associate a vector of samples with a scalar based inventory specification." unless is_vector
      self[:sample_ids] = samples.collect { |s| s.id }
      self[:sample] = samples.collect { |s| "#{s.id}: #{s.name}" }
      @samples = samples
      self
    end

    # Returns the sample id associated with the the {ISpec}. 
    # Returns nil if no sample id is associated with the {ISpec}.
    # @return [Fixnum] The sample id.
    def sample_id
      if !self[:sample_id] && self[:sample]
        self[:sample_id] = self[:sample].as_sample_id
      end
      self[:sample_id]
    end

    # Returns the array of sample ids associated with the the {ISpec}.
    # Returns nil if no sample ids are associated with the {ISpec}.
    # @return [Array] The sample id.
    def sample_ids
      self[:sample_ids]
    end    

    # Returns the item id associated with the the {ISpec}. Returns nil if no item id is associated with the {ISpec}.
    # @return [Fixnum] The item id.
    def item_id
      self[:item_id]
    end

    # Returns the array of item ids associated with the the {ISpec}. Returns nil if no item ids are associated with the {ISpec}.
    # @return [Array] The item id.
    def item_ids
      self[:item_ids]
    end    

    # Returns the container (ObjectType) id associated with the the {ISpec}.
    # Returns nil if no sample id is associated with the {ISpec}.
    # @return [Fixnum] The container id.
    def conainter_id
      self[:conainter]
    end

    # Returns the collection id associated with the the {ISpec}.
    # Returns nil if no collection id is associated with the {ISpec}.
    # @return [Fixnum] The collection id.
    def collection_id
      self[:collection_id]
    end            

    def row
      self[:row]
    end

    def column
      self[:column]
    end

    def item
      @item ||= Item.find_by_id(self.item_id.to_i)
    end

    def items
      begin
        a = self[:item_ids]
        @items ||= Item.find(a).index_by(&:id).slice(*a).values
      rescue
        @items = []
      end
      @items
    end

    def sample
      if !self.sample_id
        self[:sample_id] = self[:sample].as_sample_id
      end
      @sample ||= Sample.find_by_id(self[:sample_id])
    end

    def samples
      if !self[:sample_ids]
        self[:sample_ids] = self[:sample].collect { |s| s.as_sample_id }
      end      
      begin
        a = self[:sample_ids]
        @samples ||= Sample.find(a).index_by(&:id).slice(*a).values
      rescue
        @samples = []
      end
      @samples
    end    

    def container
      if !self[:container_id]
        self[:container_id] = self[:container].as_container_id
      end
      @container ||= ObjectType.find(self[:container_id])
    end

    def collection
      @collection ||= Collection.find_by_id(self.collection_id)
    end    

    def collections
      begin
        @collections = []
        self[:collection_ids].each do |cid|
          @collections << Collection.find(cid)
        end
      rescue
        @collections = []
      end
      @collections
    end    

    def rows
      self[:rows]
    end

    def columns
      self[:columns]
    end

    def associate slot    

      if self[:sample].class == String

        self[:collection_id] = slot.collection.id
        self[:row] = slot.row
        self[:column] = slot.column
        slot.sample = self[:sample].as_sample_id

      elsif self[:sample].class == Array

        self[:collection_ids] = []
        self[:rows] = []
        self[:columns] = []        

        s = slot

        self[:sample].each do |samp|
          self[:collection_ids] << s.collection.id
          self[:rows] << s.row
          self[:columns] << s.column
          s.sample = samp.as_sample_id
          s = s.next
        end

      end

    end    

  end

end