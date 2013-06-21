class LiasonController < ApplicationController

  def select

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

  def update

    @x = ObjectType.find_by_name(params[:name])

    if !@x
      @item = { error: params[:name].to_s + " not found in db" }
    else
      if params[:item_id]
        @item = Item.find_by_id(params[:item_id])
        if !@item
          @item = { error: "item #{params[:item_id]} not found in db" }
        else
          if params[:quantity]
            @item.quantity = params[:quantity]
          else
            @item.quantity = 0
          end
          @item.save
        end
      else
        if params[:location]
          loc = params[:location]
        else
          loc = "B1.000"
        end
        if params[:quantity]
          q = params[:quantity]
        else
          q = 0
        end
        @item = @x.items.create(location: loc, quantity: q)
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
