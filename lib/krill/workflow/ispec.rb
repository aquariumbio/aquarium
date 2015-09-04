module Krill

  module ISpec

    def sample_id
      self[:sample]
    end

    def item_id
      self[:item]
    end

    def conainter_id
      self[:conainter]
    end

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