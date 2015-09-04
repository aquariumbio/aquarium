class OperationsController < ApplicationController

  def rename
    op = Operation.find(params[:id])
    op.rename params[:name]
    render json: op.export
  end

  def rename_part
    op = Operation.find(params[:id])
    op.rename_part params[:type].to_sym, params[:old_name], params[:new_name]
    render json: op.export
  end

  def new_part
    op = Operation.find(params[:id])
    name = op.new_part params[:type].to_sym
    render json: { name: name, operation: op.export }
  end

  def drop_part
    op = Operation.find(params[:id])
    op.drop_part params[:type].to_sym, params[:name]
    render json: op.export
  end    

  def new_exception
    op = Operation.find(params[:id])
    op.new_exception
    render json: op.export
  end

  def new_exception_part
    op = Operation.find(params[:id])
    op.new_exception_part(params[:type].to_sym, params[:name])
    render json: op.export
  end

  # GET /operations
  # GET /operations.json
  def index
    @operations = Operation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @operations }
    end
  end

  # GET /operations/1
  # GET /operations/1.json
  def show
    @operation = Operation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @operation }
    end
  end

  # GET /operations/new
  # GET /operations/new.json
  def new
    @operation = Operation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @operation }
    end
  end

  # GET /operations/1/edit
  def edit
    @operation = Operation.find(params[:id])
  end

  # POST /operations
  # POST /operations.json
  def create

    @operation = Operation.new(params[:operation])
    result = @operation.save
    
    respond_to do |format|
      if result
        format.html { redirect_to @operation, notice: 'Operation was successfully created.' }
        format.json { render json: @operation, status: :created, location: @operation }
      else
        format.html { render action: "new" }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
      end
    end
  end

  def make

    @operation = Operation.new
    @operation.save
    @operation.make_generic_protocol

    render json: @operation.export

  end

  # PUT /operations/1
  # PUT /operations/1.json
  def update
    @operation = Operation.find(params[:id])

    respond_to do |format|
      if @operation.update_attributes(params[:operation])
        format.html { redirect_to @operation, notice: 'Operation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @operation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operations/1
  # DELETE /operations/1.json
  def destroy
    @operation = Operation.find(params[:id])
    @operation.destroy

    respond_to do |format|
      format.html { redirect_to operations_url }
      format.json { head :no_content }
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
    render json: Sample.where(sample_type_id: params[:id]).select([:id,:name]).collect { |h| "#{h.id}: #{h.name}" }
  end

end
