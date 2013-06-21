class LiasonController < ApplicationController

  def get

    @x = ObjectType.find_by_name(params[:name])

    if !@x
      @x = { error: params[:name].to_s + " not found in db" }
    else
      @x[:inventory] = @x.items
    end

    respond_to do |format|
      format.html # get.html.erb
      format.json { render json: @x }
    end

  end

  def put

    @x = ObjectType.find_by_name(params[:name])

    if !@x
      @item = { error: params[:name].to_s + " not found in db" }
    else
      if params[:item_id]
        @item = Item.find_by_id(params[:item_id])
        if !@item
          @item = { error: "item #{params[:item_id]} not found in db" }
        else
          @item.quantity = params[:quantity]
          @item.save
        end
      else
        @item = @x.items.create(location: params[:location], quantity: params[:quantity])
      end
    end

    respond_to do |format|
      format.html # get.html.erb
      format.json { render json: @item }
    end

  end

  def adjust
  end

end
