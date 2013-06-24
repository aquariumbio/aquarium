class ItemsController < ApplicationController

  before_filter :signed_in_user

  def create
    @object_type = ObjectType.find(params[:object_type_id])
    @item = @object_type.items.create(params[:item])

    if (@item.errors.size > 0 )
      flash[:error] = ""
      @item.errors.full_messages.each do |e|
        flash[:error] += e + " "
      end
    end

    redirect_to object_type_path(@object_type)
  end

  def destroy
    Item.find(params[:id]).destroy
    flash[:success] = "Item deleted."
    redirect_to object_type_url :id => params[:object_type_id]
  end

  def update

    i = Item.find(params[:id])

    case params['update_action']

      when 'update'
        i.quantity = params[:quantity]
        flash[:success] = "Quantity at location " + i.location + " updated to " + i.quantity.to_s if i.save

      when 'take'
        i.inuse = params[:inuse]
        flash[:success] = "Number of items at location " + i.location + " updated to " + i.inuse.to_s if i.save

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
