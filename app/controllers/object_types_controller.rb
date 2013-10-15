class ProductionObjectType < ObjectType
end

class ProductionItem < Item
end

class ProductionSampleType < SampleType
end

class ProductionSample < Sample
end

class ObjectTypesController < ApplicationController

  before_filter :signed_in_user

  # GET /object_types
  # GET /object_types.json
  def index

    @handler = params[:handler] ? params[:handler] : 'glassware'
    @all_handlers = ObjectType.pluck(:handler).uniq
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

    if @object_type.handler == 'sample_container'
      @sample_type = SampleType.find(@object_type.sample_type_id)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @object_type }
    end

  end

  # GET /object_types/new
  # GET /object_types/new.json
  def new

    @object_type = ObjectType.new

    if params[:sample_type_id]
      @sample_type = SampleType.find(params[:sample_type_id])
      @object_type.unit = @sample_type.name
      @object_type.handler = "sample_container"
      @object_type.sample_type_id = params[:sample_type_id]
    else
      @object_type.handler = "generic"
    end

    # pretty sure these defaults should go in the model and not here
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
        if @object_type.handler == 'sample_container'
          format.html { redirect_to @object_type.sample_type, notice: 'Object type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to @object_type, notice: 'Object type was successfully updated.' }
          format.json { head :no_content }
        end
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

    if Rails.env != 'production'

      num_objects = 0
      num_items = 0
      num_sample_types = 0
      num_samples = 0     
      num_touches = 0

      ObjectType.all.each do |ob|
        num_objects += 1
        num_items += ob.items.length
        ob.destroy
      end

      SampleType.all.each do |st|
        num_sample_types += 1
        num_samples += st.samples.length
        st.destroy
      end

      Touch.all.each do |t|
        num_touches += 1
        t.destroy()
      end

      redirect_to production_interface_path, notice: "Deleted #{num_objects} object types, #{num_items} items, #{num_sample_types} sample type definitions, and #{num_samples} samples from the inventory. Also deleted were #{num_touches} touches."

    else

      redirect_to production_interface_path, notice: "This functionality is not available in production mode."

    end

  end

  def copy_inventory_from_production

    if Rails.env != 'production'

      num_objects = 0
      num_items = 0
      num_sample_types = 0
      num_samples = 0

      ProductionObjectType.switch_connection_to(:production_server)
      ProductionItem.switch_connection_to(:production_server)
      ProductionSampleType.switch_connection_to(:production_server)
      ProductionSample.switch_connection_to(:production_server)

      # loop on object types
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

      # loop on sample types
      ProductionSampleType.all.each do |st|

        num_sample_types += 1

        # copy sample types
        new_st = SampleType.new(st.attributes.except("id","created_at","updated_at"))
        new_st.save

        # copy samples
        ProductionSample.where("sample_type_id = ?", st.id).each do |s|
          num_samples += 1
          new_st.samples.create(s.attributes.except("id","sample_type_id","created_at","updated_at"))
        end

      end

      redirect_to object_types_path, notice: "Copied #{num_objects} object types, #{num_items} items, #{num_sample_types} sample type definitions, and #{num_samples} samples from the production inventory."

    else

      redirect_to production_interface_path, notice: "This functionality is not available in production mode."

    end

  end

end
