class ObjectTypesController < ApplicationController

  before_filter :signed_in_user

  # GET /object_types
  # GET /object_types.json
  def index
    @object_types = ObjectType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @object_types }
    end
  end

  # GET /object_types/1
  # GET /object_types/1.json
  def show
    @object_type = ObjectType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @object_type }
    end
  end

  # GET /object_types/new
  # GET /object_types/new.json
  def new
    @object_type = ObjectType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @object_type }
    end
  end

  # GET /object_types/1/edit
  def edit
    @object_type = ObjectType.find(params[:id])
  end

  # POST /object_types
  # POST /object_types.json
  def create
    @object_type = ObjectType.new(params[:object_type])

    respond_to do |format|
      if @object_type.save
        format.html { redirect_to @object_type, notice: 'Object type was successfully created.' }
        format.json { render json: @object_type, status: :created, location: @object_type }
      else
        format.html { render action: "new" }
        format.json { render json: @object_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /object_types/1
  # PUT /object_types/1.json
  def update
    @object_type = ObjectType.find(params[:id])

    respond_to do |format|
      if @object_type.update_attributes(params[:object_type])
        format.html { redirect_to @object_type, notice: 'Object type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @object_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /object_types/1
  # DELETE /object_types/1.json
  def destroy
    @object_type = ObjectType.find(params[:id])
    @object_type.destroy

    respond_to do |format|
      format.html { redirect_to object_types_url }
      format.json { head :no_content }
    end
  end
end
