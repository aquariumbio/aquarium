class SamplesController < ApplicationController
  # GET /samples
  # GET /samples.json
  def index

    # What are the sample types?
    @all_sample_types = SampleType.all

    # Figure out which user's samples we're looking at
    @sample_type_id = params[:sample_type_id] ? params[:sample_type_id] : @all_sample_types.first.id
    @sample_type = SampleType.find(@sample_type_id)

    # Figure out which user's samples we're looking at
    @user_id = params[:user_id] ? params[:user_id] : current_user.id
    @user = User.find(@user_id)

    @samples = Sample.where("sample_type_id = :s AND user_id = :u", { s: @sample_type_id, u: @user.id })

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @samples }
    end
  end

  # GET /samples/1
  # GET /samples/1.json
  def show

    @sample = Sample.find(params[:id])
    @sample_type = @sample.sample_type

    if params[:toggle] 
      @item = Item.find(params[:toggle])
      @item.inuse = @item.inuse > 0 ? 0 : 1;
      @item.save
    end

    if params[:delete] 
      Item.find(params[:delete]).destroy
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sample }
    end
  end

  # GET /samples/new
  # GET /samples/new.json
  def new

    @sample = Sample.new
    @user = User.find(current_user)
    @sample.sample_type_id = params[:sample_type]
    @sample_type = @sample.sample_type

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sample }
    end

  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.find(params[:id])
    @user = User.find(current_user)
    @sample_type = @sample.sample_type
  end

  # POST /samples
  # POST /samples.json
  def create

    @sample = Sample.new(params[:sample])
    @user = User.find(current_user)
    @sample_type = @sample.sample_type

    respond_to do |format|
      if @sample.save
        format.html { redirect_to @sample, notice: 'Sample was successfully created.' }
        format.json { render json: @sample, status: :created, location: @sample }
      else
        format.html { render action: "new" }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /samples/1
  # PUT /samples/1.json
  def update
    @sample = Sample.find(params[:id])

    respond_to do |format|
      if @sample.update_attributes(params[:sample])
        format.html { redirect_to @sample, notice: 'Sample was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sample.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /samples/1
  # DELETE /samples/1.json
  def destroy
    @sample = Sample.find(params[:id])
    id = @sample.sample_type_id
    @sample.destroy

    respond_to do |format|
      format.html { redirect_to samples_url(sample_type_id: id) }
      format.json { head :no_content }
    end
  end
end
