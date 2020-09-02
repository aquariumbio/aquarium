# typed: false
# frozen_string_literal: true

class ObjectTypesController < ApplicationController

  helper ObjectTypesHelper

  before_filter :signed_in_user

  # GET /object_types
  # GET /object_types.json
  def index

    respond_to do |format|
      format.html do # index.html.erb
        @handler = params[:handler] || 'glassware'
        @all_handlers = ObjectType.pluck(:handler).uniq.sort
        @first = !@all_handlers.empty? ? @all_handlers[0] : 'no handlers'
        @object_types = ObjectType.all.sort_by(&:name)
        render layout: 'aq2'
      end
      format.json { render json: ObjectType.all.collect { |ot| { name: ot.name, handler: ot.handler } } }
    end

  end

  # GET /object_types/1
  # GET /object_types/1.json
  def show

    @object_type = ObjectType.includes(items: [{ locator: :wizard }, :sample]).find(params[:id])
    @handler = view_context.make_handler @object_type

    @sample_type = SampleType.find(@object_type.sample_type_id) if @object_type.sample?

    @image_url = "#{Bioturk::Application.config.image_server_interface}#{@object_type.image}"

    respond_to do |format|
      format.html { render layout: 'aq2' } # show.html.erb
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
      @object_type.handler = 'sample_container'
      @object_type.sample_type_id = params[:sample_type_id]
    else
      @object_type.handler = 'generic'
    end

    # pretty sure these defaults should go in the model and not here
    @object_type.min = 0
    @object_type.max = 1
    @object_type.safety = 'No safety information'
    @object_type.cleanup = 'No cleanup information'
    @object_type.data = 'No data'
    @object_type.vendor = 'No vendor information'
    @object_type.cost = 0.01

    respond_to do |format|
      format.html { render layout: 'aq2-plain' }
      format.json { render json: @object_type }
    end

  end

  # GET /object_types/1/edit
  def edit
    @object_type = ObjectType.find(params[:id])
    render layout: 'aq2-plain'
  end

  # POST /object_types
  # POST /object_types.json
  def create

    @object_type = ObjectType.new(params[:object_type].except(:rows, :columns))

    if params[:object_type][:handler] == 'collection'
      @object_type.rows = params[:object_type][:rows]
      @object_type.columns = params[:object_type][:columns]
    end

    respond_to do |format|
      if @object_type.save
        format.html { redirect_to object_types_url, notice: "Object type #{@object_type.name} was successfully created." }
        format.json { render json: @object_type, status: :created, location: @object_type }
      else
        format.html { render action: 'new', layout: 'aq2-plain' }
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
        render action: 'edit'
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
        format.html { redirect_to object_types_path, notice: "Object type '#{@object_type.name}' was successfully updated." }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_object_type_path, notice: "Object type could not be updated. #{@object_type.errors.full_messages.join(', ')}." }
        format.json { render json: @object_type.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /object_types/1
  # DELETE /object_types/1.json
  def destroy
    @object_type = ObjectType.find(params[:id])

    if !@object_type.items.empty?
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

  def copy_table(from, to)

    all_inserts = from.all.collect do |pw|
      '(' + (pw.attributes.values.collect do |v|
        if v.class == String
          "'#{v.gsub(/'/) { |_s| "''" }}'"
        elsif v.class == ActiveSupport::TimeWithZone
          "'#{v}'"
        elsif v.nil?
          'NULL'
        else
          v
        end
      end).join(',') + ')'
    end

    columns = from.column_names

    max = 500

    0..(all_inserts.length / max).each do |i|

      inserts = all_inserts[max * i, max]
      next if inserts.empty?

      puts "inserting #{max * i} to #{max * i + max}"
      sql = "INSERT INTO #{to} (#{columns.join(',')}) VALUES #{inserts.join(',')}"
      ActiveRecord::Base.connection.execute sql

    end

  end

  def containers
    render json: ObjectType.select(%i[id name]).collect { |h| "#{h.id}: #{h.name}" }
  end

  def collection_containers
    render json: ObjectType.select(%i[id name]).collect { |h| "#{h.id}: #{h.name}" }
  end

  def sample_types
    render json: SampleType.select(%i[id name]).collect { |h| "#{h.id}: #{h.name}" }
  end

  def samples
    if params[:id]
      render json: Sample.where(sample_type_id: params[:id]).select(%i[id name]).collect { |h| "#{h.id}: #{h.name}" }
    else
      render json: Sample.select(%i[id name]).collect { |h| "#{h.id}: #{h.name}" }
    end
  end

end
