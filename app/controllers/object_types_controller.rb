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

    respond_to do |format|
      format.html { # index.html.erb
        @handler = params[:handler] ? params[:handler] : 'glassware'
        @all_handlers = ObjectType.pluck(:handler).uniq
        @object_types = ObjectType.where("handler = ?", @handler)
      }
      format.json { render json: ObjectType.all.collect { |ot| { name: ot.name, handler: ot.handler } } }
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
    @object_type = ObjectType.new(params[:object_type].except(:rows, :columns))

    if params[:handler] == 'collection'
      @object_type.rows = params[:object_type][:rows]
      @object_type.columns = params[:object_type][:columns]
    end

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

    ok = @object_type.update_attributes(params[:object_type].except(:rows, :columns))

    if params[:object_type][:handler] == 'collection'
      @object_type.rows = params[:object_type][:rows]
      @object_type.columns = params[:object_type][:columns]
      @object_type.save
    end

    respond_to do |format|
      if ok
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

    if @object_type.items.length > 0
      flash[:notice] = "Could not delete object type definition #{@object_type.name} because it has items associated with it."
    else
      @object_type.destroy
    end

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

      CartItem.delete_all
      ObjectType.delete_all
      Item.delete_all
      SampleType.delete_all
      Sample.delete_all
      Touch.delete_all
      Locator.delete_all
      Wizard.delete_all

      redirect_to production_interface_path, notice: "Deleted inventory. Pretty fast, huh?"

    else

      redirect_to production_interface_path, notice: "This functionality is not available in production mode."

    end

  end

  def copy_table from, to

    all_inserts = from.all.collect { |pw| 
      "(" + (pw.attributes.values.collect { |v| 
        if v.class == String 
          "'#{v.gsub(/'/) {|s| "''"}}'"
        elsif v.class == ActiveSupport::TimeWithZone          
          "'#{v}'"
        elsif v == nil
          "NULL"
        else          
            v
        end
      }).join(',') + ")"
    }

    columns = from.column_names

    max = 500

    for i in 0..(all_inserts.length/max)

      inserts = all_inserts[max*i,max]
      if inserts.length > 0
        puts "inserting #{max*i} to #{max*i+max}"
        sql = "INSERT INTO #{to} (#{columns.join(',')}) VALUES #{inserts.join(',')}"
        ActiveRecord::Base.connection.execute sql
      end

    end

  end

  def containers
    render json: ObjectType.select([:id,:name]).collect { |h| "#{h.id}: #{h.name}" }
  end

  def collection_containers
    render json: ObjectType.select([:id,:name]).collect { |h| "#{h.id}: #{h.name}" }
  end    

  def sample_types
    render json: SampleType.select([:id,:name]).collect { |h| "#{h.id}: #{h.name}" }
  end  

  def samples
    if params[:id]
      render json: Sample.where(sample_type_id: params[:id]).select([:id,:name]).collect { |h| "#{h.id}: #{h.name}" }
    else
      render json: Sample.select([:id,:name]).collect { |h| "#{h.id}: #{h.name}" }      
    end
  end  

  def copy_inventory_from_production

    if Rails.env != 'production'

      ProductionObjectType.switch_connection_to(:production_server)
      ProductionItem.switch_connection_to(:production_server)
      ProductionSampleType.switch_connection_to(:production_server)
      ProductionSample.switch_connection_to(:production_server)
      ProductionLocator.switch_connection_to(:production_server)
      ProductionWizard.switch_connection_to(:production_server)

      copy_table ProductionWizard, "wizards"
      copy_table ProductionLocator, "locators"
      copy_table ProductionObjectType, "object_types"
      copy_table ProductionItem, "items"
      copy_table ProductionSampleType, "sample_types"
      copy_table ProductionSample, "samples"

      redirect_to object_types_path, notice: "Copied #{ObjectType.count} object types, #{Item.count} items, #{SampleType.count} sample types, #{Sample.count} samples, #{Wizard.count} wizards, and #{Locator.count} locators. Whew."

    else

      redirect_to production_interface_path, notice: "This functionality is not available in production mode."

    end

  end

end
