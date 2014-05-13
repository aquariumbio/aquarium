module ObjectTypesHelper

  def make_handler ot

    case ot.handler

      when 'collection'
        CollectionHandler.new ot
      when 'sample_container'
        SampleContainerHandler.new ot
      else
        Handler.new ot
    end

  end

  class Handler

    def initialize object_type
      @object_type = object_type
    end

    def new_item_partial
       "handlers/default_new_item"
    end

    def current_inventory_partial
       "handlers/default_current_inventory"
    end

    def show_item_partial
      "handlers/default_show_item"
    end

    def new_item params
      @object_type.items.create(params[:item])
    end

  end

  class CollectionHandler < Handler

    def initialize object_type
      super object_type
    end

    def new_item_partial
       "handlers/collection_new_item"
    end

    def current_inventory_partial
       "handlers/collection_current_inventory"
    end

    def show_item_partial
      "handlers/collection_show_item"
    end

    def new_item params

      r = params[:item][:rows].to_i
      c = params[:item][:cols].to_i
      params[:item].delete(:rows)
      params[:item].delete(:cols)
      item = @object_type.items.create(params[:item])
    
      item.quantity = 1
      item.data = Array.new(r,Array.new(c,0)).to_json
      item

    end

    def matrix item

      begin
        m = JSON.parse item.data
      rescue Exception => e
        m = nil
      end

      if m.class == Array && m.length > 0 && m[0].class == Array
        m
      else
        [[]]
      end

    end

    def size item
      m = matrix item
      [ m.length, m[0].length ]
    end

  end

  class SampleContainerHandler < Handler

    def initialize object_type
      super object_type
    end

    def new_item_partial
       "handlers/sample_container_new_item"
    end

    def current_inventory_partial
       "handlers/sample_container_current_inventory"
    end

    def show_item_partial
      "handlers/sample_container_show_item"
    end

  end


end
