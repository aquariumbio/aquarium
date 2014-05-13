class ItemsController < ApplicationController

  before_filter :signed_in_user

  def show

    @item = Item.find_by_id(params[:id])
    @object_type = @item.object_type
    @handler = view_context.make_handler @object_type

    if @item == nil
      flash[:error] = "Could not find item with id #{params[:id]}"
      redirect_to search_path
      return
    end

    @active_item = params[:active_item]
    @touches = @item.touches

    flash.delete :error

    if /^[0-9a-zA-Z]*\.[0-9]*\.[0-9]*\.[0-9]*$/ =~ @item.location
      @box_name = @item.location.split('.')[0..2].join('.')
      re = @item.location.split('.')[0..2].join('\.') + '\.'
      @box = Array.new(81) {nil}
      (Item.includes(:sample).includes(:object_type).select { |i| (Regexp.new re) =~ i.location }).each do |i| 
        f,h,b,s = i.location.split('.')
        if @box[s.to_i] != nil
          if !flash[:error]
            flash[:error] = ["<b>WARNING!</b>"]
          end
          flash[:error] << "#{@box_name}.#{s} contains multiple items: #{@box[s.to_i].id} and #{i.id}"
        end
        @box[s.to_i] = i
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end

  end

  def check_sample_collision loc # raises a warning if two or more items are in the given location

    items = Item.where('location = ?', loc)
    if items.length > 1
      ids = items.collect{|i|i.id}
      if loc != "Bench"
        flash[:error] = "WARNING: Sample items #{ids} have the same location, #{loc}. Please correct this problem immediately!"
      end
    end

  end

  def create

    @object_type = ObjectType.find(params[:object_type_id])

    if !params[:item][:location] 
      if params[:item][:sample_id]
        @sample = Sample.find(params[:item][:sample_id])
        params[:item][:location] = @object_type.location_wizard( { project: @sample ? @sample.project : 'unknown' } )
      else
        params[:item][:location] = @object_type.location_wizard
      end
    end

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

      check_sample_collision( @item.location )
      redirect_to sample_path( @item.sample )     

    else

      redirect_to object_type_path(@object_type)

    end

  end

  def destroy
    x = Item.find(params[:id])
    x.inuse    = -1
    x.quantity = -1
    x.location = 'deleted'
    x.save
    flash[:success] = "Item #{params[:id]} has been #{x.location}."
    redirect_to object_type_url :id => params[:object_type_id]
  end

  def update

   if params[:item] # called from sample page

       i = Item.find(params[:item][:id])
       i.location = params[:item][:location]
       i.data = params[:item][:data]
       i.save
       check_sample_collision( i.location )

     logger.info "Params = #{params.inspect}"

       if params[:item][:return_page] == 'item_show'
         redirect_to item_url :id => i.id
       else
         redirect_to sample_url( { id: i.sample_id, active_item: i.id } )
       end

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
        if @object_type && @object_type.handler == 'sample_container'
          check_sample_collision( i.location )
        end

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

end
