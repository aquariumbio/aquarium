module Krill

  # This module is used to extend hashes that represent inventory specifications in operations. 
  module ISpec

    # Returns true if the ispec refers to a vector of samples, items, parts, or containers
    def is_vector
      self[:is_vector]
    end

    # Returns the sample id associated with the the {ISpec}. 
    # Returns nil if no sample id is associated with the {ISpec}.
    # @return [Fixnum] The sample id.
    def sample_id
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
        @items ||= Item.find(self.item_ids)
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
        self[:sample_ids] = self[:samples].collect { |s| s.as_sample_id }
      end      
      begin
        @samples ||= Sample.find(self[:sample_ids])
      rescue
        @samples = []
      end
      @samples
    end    

    def container
      @container ||= ObjectType.find(self.container_id)
    end

    def collection
      @collection ||= Collection.find_by_id(self.collection_id)
    end    

    def associate slot    

      self[:collection] = slot.collection.id
      self[:row] = slot.row
      self[:col] = slot.col
      slot.sample = self[:sample]

    end    

  end

end