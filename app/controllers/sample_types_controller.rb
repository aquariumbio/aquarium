class SampleTypesController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user  

  # GET /sample_types
  # GET /sample_types.json
  def index
    @sample_types = SampleType.all.sort_by { |st| st.name }
    if @sample_types.any?
      @first = @sample_types[0].name
    else
      @first = 'no sample types'
    end

    respond_to do |format|
      format.html { render layout: 'aq2' }
      format.json { render json: @sample_types
                                 .sort { |a,b| a.name <=> b.name }
                                 .to_json(methods: :field_types)
                  }
    end
  end

  def show

    @sample_type = SampleType.find(params[:id])

    respond_to do |format|
      format.html { render layout: 'aq2-plain' }
      format.json { render json: @sample_type
                       .to_json(methods: :field_types) }
    end

  end

  # GET /sample_types/new
  # GET /sample_types/new.json
  def new
    @sample_type = SampleType.new

    respond_to do |format|
      format.html { render layout: 'aq2-plain'}
      format.json { render json: @sample_type }
    end
  end

  # GET /sample_types/1/edit
  def edit
    @sample_type = SampleType.find(params[:id])
    render layout: 'aq2-plain'
  end

  # POST /sample_types.json
  def create

    st = SampleType.new params[:sample_type].except(:field_types)
    st.save
    st.save_field_types(params[:sample_type][:field_types])

    render json: { sample_type: st }

  end

  # PUT /sample_types/1
  # PUT /sample_types/1.json
  def update

    raw = params[:sample_type]
    st = SampleType.find(raw[:id])

    st.name = raw[:name]
    st.description = raw[:description]
    st.save
    st.save_field_types raw[:field_types]

    render json: { sample_type: st }

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
