# frozen_string_literal: true

module ObjectTypesHelper

  def make_handler(ot)
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

    def initialize(object_type)
      @object_type = object_type
    end

    def new_item_partial
      'handlers/default_new_item'
    end

    def current_inventory_partial
      'handlers/default_current_inventory'
    end

    def show_item_partial
      'handlers/default_show_item'
    end

    def new_item(params)
      Item.make(params[:item], object_type: @object_type)
    end

  end

  class CollectionHandler < Handler

    def initialize(object_type)
      super object_type
    end

    def new_item_partial
      'handlers/collection_new_item'
    end

    def current_inventory_partial
      'handlers/collection_current_inventory'
    end

    def show_item_partial
      'handlers/collection_show_item'
    end

    def new_item(params)

      r = params[:item][:rows].to_i
      c = params[:item][:cols].to_i

      item = Item.make({
                         quantity: 1,
                         inuse: 0,
                         data: { matrix: Array.new(r, Array.new(c, -1)) }.to_json
                       }, object_type: @object_type)

      item.location = params[:item][:location]
      item

    end

    def matrix(item)

      begin
        m = JSON.parse(item.data, symbolize_names: true)
      rescue JSON::ParseError
        m = nil
      end

      if m.class == Hash && m[:matrix] && m[:matrix].class == Array && !m[:matrix].empty? && m[:matrix][0].class == Array
        m[:matrix]
      else
        [[]]
      end

    end

    def size(item)
      m = matrix item
      [m.length, m[0].length]
    end

  end

  class SampleContainerHandler < Handler

    def initialize(object_type)
      super object_type
    end

    def new_item_partial
      'handlers/sample_container_new_item'
    end

    def current_inventory_partial
      'handlers/sample_container_current_inventory'
    end

    def show_item_partial
      'handlers/sample_container_show_item'
    end

  end

end
