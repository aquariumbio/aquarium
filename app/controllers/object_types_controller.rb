class ProductionObjectType < ObjectType
end

class ProductionItem < Item
end

class ObjectTypesController < ApplicationController

  before_filter :signed_in_user

  # GET /object_types
  # GET /object_types.json
  def index

    @handler = params[:handler] ? params[:handler] : 'glassware'
    @all_handlers = ObjectType.uniq.pluck(:handler)
    @object_types = ObjectType.where("handler = ?", @handler)

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

    # pretty sure these defaults should go in the model and not here
    @object_type.handler = "generic"
    @object_type.min = 0
    @object_type.max = 1
    @object_type.safety = "No safety information"
    @object_type.cleanup = "No cleanup information"
    @object_type.data = "No data"
    @object_type.vendor = "No vendor information"
    @object_type.cost = 0.01

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

  def production_interface

    respond_to do |format|
      format.html
    end

  end

  def delete_inventory

    num_objects = 0
    num_items = 0

    ObjectType.all.each do |ob|
      num_objects += 1
      num_items += ob.items.length
      ob.destroy
    end  

    redirect_to production_interface_path, notice: "Deleted #{num_objects} object types and #{num_items} items from the inventory."

  end

  def copy_inventory_from_production

    num_objects = 0
    num_items = 0

    ProductionObjectType.switch_connection_to(:production_server)
    ProductionItem.switch_connection_to(:production_server)

    ProductionObjectType.all.each do |ot|

      num_objects += 1

      # copy object type to local server
      new_ot = ObjectType.new(ot.attributes.except("id","image_file_name","image_content_type","image_file_size","image_updated_at","created_at","updated_at"))
      new_ot.save

      # copy all the items to the local server
      ProductionItem.where("object_type_id = ?", ot.id ).each do |i|
        new_ot.items.create(i.attributes.except("id","object_type_id","created_at","updated_at"))
        num_items += 1
      end

    end

    redirect_to object_types_path, notice: "Copied #{num_objects} object types and #{num_items} items from the production inventory."

  end

end
