class ItemsController < ApplicationController

  before_filter :signed_in_user

  def index

    if params[:type] == 'collection' 

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: CollectionsDatatable.new(view_context) }
      end

    else

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: ItemsDatatable.new(view_context) }
      end

    end

  end

  def show

    @item = Item.find_by_id(params[:id])

    if @item == nil
      flash[:error] = "Could not find item with id #{params[:id]}"
      redirect_to search_path
      return
    end
    
    @object_type = @item.object_type
    @handler = view_context.make_handler @object_type

    @active_item = params[:active_item]
    @touches = @item.touches

    if @item.locator 
      @wizard = @item.locator.wizard
      @box = @item.locator.to_s.split('.')[0..2].join('.')
    end

    flash.delete :error

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end

  end

  def create

    @object_type = ObjectType.find(params[:object_type_id])

    @handler = view_context.make_handler @object_type

    @item = @handler.new_item params 
    @item.save

    if (@item.errors.size > 0 )
      flash[:error] = ""
      @item.errors.full_messages.each do |e|
        flash[:error] += e + " "
      end
    end

    if @object_type.handler == 'sample_container'

      redirect_to sample_path( @item.sample )     

    else

      redirect_to object_type_path(@object_type)

    end

  end

  def make # used by the browser to create new items

    object_type = ObjectType.find(params[:oid])
    handler = view_context.make_handler object_type
    item = handler.new_item item: { quantity: 1, sample_id: params[:sid] }, object_type_id: object_type.id
    item.save

    if !item.errors.empty?
      render json: { errors: item.errors.full_messages }
    else 
      render json: { item: item.as_json(include: [:locator]) }
    end

  end

  def destroy

    i = Item.find(params[:id])
    i.mark_as_deleted
    flash[:success] = "Item #{params[:id]} has been deleted."

    respond_to do |format|
      format.html {
        puts "HTML"
        if params[:sample_id]
          redirect_to sample_url :id => params[:sample_id]
        else
          redirect_to object_type_url :id => i.object_type_id
        end
      }
      format.json { 
        puts "JSON"
        render json: i
      }
    end    

  end

  def move
    i = Item.find(params[:id])
    i.move_to params[:location]
    render json: { message: "Item #{i.id} successfully moved to #{i.location}" } if i.errors.empty?
    render json: { error: "Could not move item #{i.id} to #{params[:location]}: #{i.errors.full_messages.join(', ')}" } unless i.errors.empty?  
  end

  def store
    i = Item.find(params[:id])
    i.store
    render json: i if i.errors.empty?
    render json: { error: "Could not move item #{i.id} to #{params[:location]}: #{i.errors.full_messages.join(', ')}" }, status: 422 unless i.errors.empty?  
  end

  def update

    if params[:item] 

      i = Item.find(params[:item][:id])
      i.data = params[:item][:data]
      i.save

      i.location = params[:item][:location] # this saves the item too
      flash[:warning] = "Could not move item: #{i.errors.full_messages.join(',')}" unless i.errors.empty?

      if params[:item][:return_page] == 'item_show'
        redirect_to item_url :id => i.id
      else
        redirect_to sample_url( { id: i.sample_id, active_item: i.id } )
      end

    else # called with just the id

      i = Item.find(params[:id])

      case params['update_action']

        when 'update'
          i.quantity = params[:quantity]
          flash[:success] = "Quantity at location " + i.location + " updated to " + i.quantity.to_s if i.save

        when 'take'
          i.inuse = params[:inuse]
          flash[:success] = "Number of items at location " + i.location + " updated to " + i.inuse.to_s if i.save

        when 'move'
          i.move_to params[:location]
          flash[:success] = "Item #{i.id} moved to #{i.location}" if i.errors.empty?
          flash[:error] = "Could not move item #{i.id} to #{i.location}." unless i.errors.empty?        

      end

      if ( i.errors.size > 0 )
        flash[:error] = ""
        i.errors.full_messages.each do |e|
          flash[:error] += e + " "
        end
      end

      if params[:return_page] == 'item_show'
        redirect_to item_url :id => i.id
      else
        redirect_to object_type_url :id => params[:oid]
      end

    end

  end

  def item_list

    data = "id,object type,sample,sample type,location,user,created,updated\n"

    Item.includes(:object_type, sample: [:sample_type,:user], locator: [:wizard]).all.each do |i|
      if !i.deleted?
        if i.object_type
          oname = i.object_type.name
        else
          oname = ""
        end
        if i.sample
          sname = i.sample.name
          stype = i.sample.sample_type.name
          if i.sample.user
            user = i.sample.user.login
          else
            user = ""
          end
        else
          sname = ""
          stype = ""
          user = ""
        end
        data += "#{i.id},#{oname},\"#{sname}\",#{stype},#{i.location},#{user},#{i.created_at},#{i.updated_at}\n"
      end
    end

    render text: data

  end

  def history
    render json: Serialize.item_history(Item.find(params[:id]))
  end

end
