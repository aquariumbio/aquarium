class ItemsController < ApplicationController

  before_filter :signed_in_user

  def create
    @object_type = ObjectType.find(params[:object_type_id])
    @item = @object_type.items.create(params[:item])
    redirect_to object_type_path(@object_type)
  end

  def destroy
    Item.find(params[:id]).destroy
    flash[:success] = "Item deleted."
    redirect_to object_type_url :id => params[:object_type_id]
  end

  def update
    i = Item.find(params[:id])
    i.quantity = params[:quantity]
    i.save
    flash[:success] = "Quantity at location " + i.location \
                    + " updated to " + i.quantity.to_s
    redirect_to object_type_url :id => params[:oid]
  end

end
