class ProductionObjectType < ObjectType
end

class ProductionItem < Item
end

class ProductionSampleType < SampleType
end

class ProductionSample < Sample
end

class ProductionLocator < Locator
end

class ProductionWizard < Wizard
end

class ObjectTypesController < ApplicationController

  helper ObjectTypesHelper

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

    @object_type = ObjectType.includes( items: [ { locator: :wizard}, :sample ] ).find(params[:id])
    @handler = view_context.make_handler @object_type

    if @object_type.handler == 'sample_container'
      @sample_type = SampleType.find(@object_type.sample_type_id)
    end

    @image_url = "#{Bioturk::Application.config.image_server_interface}#{@object_type.image}"

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

    if params[:object_type][:prefix] != @object_type.prefix 
      entries = Item.joins(:locator).where("items.object_type_id = #{@object_type.id} AND locators.item_id = items.id").count
      if entries != 0
        flash[:error] = "Cannot change location wizard to #{params[:object_type][:prefix]} because there 
                      are items associated with this object type using the current wizard whose locations 
                      might get messed up. To change the wizard, (a) write down all the item numbers; (b)
                      delete all the items; (c) change the location wizard; (d) undelete all the items by
                      changing their locations to a location that works with the new location wizard."
        render action: "edit"
        return
      end
    end

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

      CartItem.all.each do |c|
        c.destroy
      end

      ObjectType.includes(:items).each do |ob|
        num_objects += 1
        num_items += ob.items.length
        ob.destroy
      end

      Item.all.each do |i| # this should destroy any orphans
        num_items += 1
        i.destroy
      end

      SampleType.includes(:samples).each do |st|
        num_sample_types += 1
        num_samples += st.samples.length
        st.destroy
      end

      Sample.all.each do |s| # this should destroy any orphans
        num_samples += 1
        s.destroy
      end

      Touch.all.each do |t|
        num_touches += 1
        t.destroy()
      end

      Locator.all.each do |l|
        i.destroy()
      end

      Wizard.all.each do |w|
        w.destroy()
      end

      redirect_to production_interface_path, notice: "Deleted #{num_objects} object types, #{num_items} items, #{num_sample_types} sample type definitions, and #{num_samples} samples from the inventory. All users carts were emptied. Also deleted were #{num_touches} touches."

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
      ProductionLocator.switch_connection_to(:production_server)
      ProductionWizard.switch_connection_to(:production_server)

      ProductionObjectType.all.each do |ot|

        num_objects += 1
        new_ot = ObjectType.new(ot.attributes.except("image_file_name","image_content_type","image_file_size","image_updated_at","updated_at"))
        new_ot.id = ot.id
        new_ot.save

      end

      ProductionItem.all.each do |i|

        new_item = Item.new(i.attributes.except("object_type_id","updated_at","locator_id","location"))
        new_item.id = i.id # Not sure why there was a + 1 here, but it has been commented out now.
        new_item.object_type_id = i.object_type_id
        new_item.sample_id = i.sample_id
        new_item.locator_id = i.locator_id        
        new_item.write_attribute(:location,i.location)
        new_item.save
        num_items += 1

      end

      ProductionSampleType.all.each do |st|

        num_sample_types += 1
        new_st = SampleType.new(st.attributes.except("created_at","updated_at"))
        new_st.id = st.id
        new_st.save

     end

     ProductionSample.all.each do |s|

        num_samples += 1
        new_sample = Sample.new(s.attributes.except("sample_type_id","created_at","updated_at"))
        new_sample.created_at = s.created_at
        new_sample.updated_at = s.updated_at        
        new_sample.sample_type_id = s.sample_type_id
        new_sample.id = s.id
        new_sample.save

      end

      ProductionWizard.all.each do |w|
        new_wiz = Wizard.new(w.attributes)
        new_wiz.created_at = w.created_at
        new_wiz.updated_at = w.updated_at  
        new_wiz.id = w.id
        new_wiz.save
      end

      ProductionLocator.all.each do |l|
        new_loc = Locator.new(l.attributes.except("item_id"))
        new_loc.created_at = l.created_at
        new_loc.updated_at = l.updated_at  
        new_loc.item_id = l.item_id
        new_loc.id = l.id
        new_loc.save
      end

      redirect_to object_types_path, notice: "Copied #{num_objects} object types, #{num_items} items, #{num_sample_types} sample type definitions, and #{num_samples} samples from the production inventory."

    else

      redirect_to production_interface_path, notice: "This functionality is not available in production mode."

    end

  end

end
