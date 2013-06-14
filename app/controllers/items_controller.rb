class ItemsController < ApplicationController

  def create
    @object_type = ObjectType.find(params[:object_type_id])
    @item = @object_type.items.create(params[:item])
    redirect_to object_type_path(@object_type)
  end

  def destroy
    Item.find(params[:id]).destroy
    flash[:success] = "Item deleted." + params.to_s
    redirect_to object_type_url :id => params[:object_type_id]
  end

end
