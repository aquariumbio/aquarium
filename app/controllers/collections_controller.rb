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
    
  end

  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy
    redirect_to collections_url
  end

end
