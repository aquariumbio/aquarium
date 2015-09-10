module Krill

  # This module is used to extend hashes that represent inventory specifications in operations. 
  module ISpec

    # Returns the sample id associated with the the {ISpec}. Returns nil if no sample id is associated with the {ISpec}.
    # @return [Fixnum] The sample id.
    def sample_id
      self[:sample]
    end

    # Returns the item id associated with the the {ISpec}. Returns nil if no item id is associated with the {ISpec}.
    # @return [Fixnum] The item id.
    def item_id
      self[:item]
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
      self[:collection]
    end            

    def row
      self[:row]
    end

    def col
      self[:col]
    end

    def column
      self[:col]
    end

    def sample
      @sample ||= Sample.find(self.sample_id)
    end

    def item
      @item ||= Item.find(self.item_id)
    end

    def container
      @container ||= ObjectType.find(self.container_id)
    end

    def collection
      @collection ||= Collection.find(self.collection_id)
    end    

    def associate slot    

      self[:collection] = slot.collection.id
      self[:row] = slot.row
      self[:col] = slot.col
      slot.sample = self[:sample]

    end    

  end

end