class ItemsController < ApplicationController

  before_filter :signed_in_user

  def show

    @item = Item.find(params[:id])
    @active_item = params[:active_item]
    @touches = @item.touches

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end

  end

  def create
    @object_type = ObjectType.find(params[:object_type_id])
    @item = @object_type.items.create(params[:item])
    @item.location = @object_type.location_wizard({project: @item.sample.project})
    @item.save

    if (@item.errors.size > 0 )
      flash[:error] = ""
      @item.errors.full_messages.each do |e|
        flash[:error] += e + " "
      end
    end

    if @object_type.handler == 'sample_container'
      redirect_to sample_path(@item.sample)     
    else
      redirect_to object_type_path(@object_type)
    end

  end

  def destroy
    Item.find(params[:id]).destroy
    flash[:success] = "Item deleted."
    redirect_to object_type_url :id => params[:object_type_id]
  end

  def update

   if params[:item] # called from sample page

       i = Item.find(params[:item][:id])
       i.location = params[:item][:location]
       i.data = params[:item][:data]
       i.save
       redirect_to sample_url( { id: i.sample_id, active_item: i.id } )

   else

    i = Item.find(params[:id])

    case params['update_action']

      when 'update'
        i.quantity = params[:quantity]
        flash[:success] = "Quantity at location " + i.location + " updated to " + i.quantity.to_s if i.save

      when 'take'
        i.inuse = params[:inuse]
        flash[:success] = "Number of items at location " + i.location + " updated to " + i.inuse.to_s if i.save

      when 'move'
        old_loc = i.location
        i.location = params[:location]
        flash[:success] = "Item #{i.id} moved from #{old_loc} to #{i.location}" if i.save

   end

    if ( i.errors.size > 0 )
      flash[:error] = ""
      i.errors.full_messages.each do |e|
        flash[:error] += e + " "
      end
    end

    redirect_to object_type_url :id => params[:oid]

    end

  end

end
