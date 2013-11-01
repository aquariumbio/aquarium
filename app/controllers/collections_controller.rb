require 'matrix'

class CollectionsController < ApplicationController

  def index
    @collections = Collection.all
  end

  def new
    @collection = Collection.new
    @collection_objects = ObjectType.where(handler: 'collection')
  end

  def create
    @collection = Collection.create(params[:collection])
    redirect_to collections_path, notice: 'New collection created.'
  end

  def show
    @collection = Collection.find(params[:id])
    @matrix = @collection.matrix
    render 'show'
  end

  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy
    redirect_to collections_url
  end

  def associate

    @item = Item.find(params[:item])

    if @item && !@item.part

      p = Part.new
      p.row = params[:r]
      p.column = params[:c]
      p.collection_id = params[:id]
      p.item_id = @item.id
      p.save

      flash[:notice] = "Associated item #{@item.id} with (#{params[:r]},#{params[:c]})."

    else

      msg =  "Could not associate item #{params[:id]} because "
      msg += "it is already associated with part (#{@item.part.row}, #{@item.part.column}) "
      msg += "of collection #{@item.part.collection.id}."
      flash[:notice] = msg

    end

    show

  end

  def dissociate

    p = Part.where( { row: params[:r], column: params[:c], collection_id: params[:id], item_id: params[:item] } )

    if p.length > 0
      p.first.destroy
      flash[:notice] = "Dissociated item #{params[:id]} from (#{params[:r]},#{params[:c]})."
    else
      flash[:notice] = "Could not find the specified association for part (#{params[:r]},#{params[:c]}) and item #{params[:item]}"
    end

    show

  end

  def newitem

    st = SampleType.find_by_name(params[:type])
    ss  = st.samples.select { |s| s.name == params[:sample] && s.project == params[:project] }
    ots = st.object_types.select { |ot| ot.name == params[:container] }

    if st && ss.length > 0 && ots.length > 0
      i = Item.new
      i.quantity = 1
      i.location = "part of collection"
      i.inuse = 0
      i.sample_id = ss.first.id
      i.object_type_id = ots.first.id
      i.data = "{}"
      i.save
      flash[:notice] = "Created new item #{i.attributes.to_s}"
    else 
      flash[:error] = "Could not make new item for collection"
    end

    show

  end

end
