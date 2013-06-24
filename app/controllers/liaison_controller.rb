class LiaisonController < ApplicationController

  def info

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

  def take

    @x = Item.find_by_id(params[:id])

    if !@x
      @x = { error: 'Item' + params[:id].to_s + " not found in db" }
    else
      @x.inuse += params[:quantity].to_i
      @x.save
      if @x.errors.size > 0 
        @x = { error: @x.errors }
      end
    end

    respond_to do |format|
      format.html # get.html.erb
      format.json { render json: @x }
    end

  end

  def produce

    @x = ObjectType.find_by_name(params[:name])

    if !@x
      @item = { error: params[:name].to_s + " not found in db" }
    else
      if params[:id]
        @item = Item.find_by_id(params[:id])
        if !@item
          @item = { error: "item #{params[:item_id]} not found in db" }
        else
          if params[:quantity]
            @item.quantity += params[:quantity].to_i
          else
            @item.quantity = 1
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
          q = 1
        end
        @item = @x.items.create(location: loc, quantity: q)
      end
    end

    respond_to do |format|
      format.html # get.html.erb
      format.json { render json: @item }
    end

  end

  def release

    @x = Item.find_by_id(params[:id])

    if !@x
      @x = { error: 'Item' + params[:id].to_s + " not found in db" }
    else

      m = @x.object_type.release_method
      if m == 'query'
        m = params[:method]
      end

      case m

        when 'return'
          @x.inuse -= params[:quantity].to_i

        when 'dispose'
          @x.inuse    -= params[:quantity].to_i
          @x.quantity -= params[:quantity].to_i

      end

      @x.save

      if @x.errors.size > 0 
        @x = { error: @x.errors }
      end

    end

    respond_to do |format|
      format.html # get.html.erb
      format.json { render json: @x }
    end

  end

end
