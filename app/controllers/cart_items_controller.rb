class CartItemsController < ApplicationController

  before_filter :signed_in_user

  # GET /carts
  # GET /carts.json
  def index

    @user = if params[:user_id]
              User.find(params[:user_id])
            else
              current_user
            end

    @cart_items = @user.cart_items

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cart_items }
    end
  end

  def new

    @item = Item.find(params[:item_id])

    # check whether the item is already in the cart
    i = CartItem.find(:first, conditions: { user_id: current_user.id, item_id: params[:item_id] })

    if !i
      @ci = current_user.cart_items.create(item_id: params[:item_id])
      redirect_to @item.sample, notice: "Item #{@item.id} (#{@item.object_type.name}) added to your cart."
    else
      redirect_to @item.sample, notice: "Item #{@item.id} (#{@item.object_type.name}) is already in your cart."
    end

  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy

    respond_to do |format|
      format.html { redirect_to cart_items_url }
      format.json { head :no_content }
    end
  end

end
