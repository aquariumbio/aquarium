class SampleTypesController < ApplicationController

  before_filter :signed_in_user

  # GET /sample_types
  # GET /sample_types.json
  def index
    @sample_types = SampleType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sample_types }
    end
  end

  def show
    @sample_type = SampleType.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sample }
    end
  end

  # GET /sample_types/new
  # GET /sample_types/new.json
  def new
    @sample_type = SampleType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sample_type }
    end
  end

  # GET /sample_types/1/edit
  def edit
    @sample_type = SampleType.find(params[:id])
  end

  # POST /sample_types
  # POST /sample_types.json

  def build st, p

    logger.info "p = #{p}"

    st.name = p[:name]
    st.description = p[:description]

    (1..8).each do |i|
      ft = "field#{i}type".to_sym
      fn = "field#{i}name".to_sym
      st[fn] = p[fn]
      val = p[ft]
      if !val 
        st[ft] = "not used"
      elsif val.length == 1
        st[ft] = val[0]
      else        
        st[ft] = val[0..val.length].join "|"
      end
      logger.info "#{fn} => #{p[fn]} and #{ft} => #{st[ft]}"
    end

    st

  end

  def create

    @sample_type = build SampleType.new, params[:sample_type]

    respond_to do |format|
      if @sample_type.save
        format.html { redirect_to action: 'index', notice: 'Sample type was successfully created.' }
        format.json { render json: @sample_type, status: :created, location: @sample_type }
      else
        format.html { render action: "new" }
        format.json { render json: @sample_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sample_types/1
  # PUT /sample_types/1.json
  def update

    @sample_type = build SampleType.find(params[:id]), params[:sample_type]

    respond_to do |format|
      if @sample_type.save
        format.html { redirect_to action: 'index', notice: 'Sample type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sample_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sample_types/1
  # DELETE /sample_types/1.json
  def destroy

    @sample_type = SampleType.find(params[:id])

    if @sample_type.samples.length > 0
      flash[:notice] = "Could not delete sample type definition #{@sample_type.name} because it has samples associated with it."
    else
      @sample_type.destroy
    end

    respond_to do |format|
      format.html { redirect_to sample_types_url }
      format.json { head :no_content }
    end
  end
end
