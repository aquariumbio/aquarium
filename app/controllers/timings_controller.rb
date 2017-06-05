class TimingsController < ApplicationController

  before_filter :signed_in_user

  # POST /timings
  # POST /timings.json
  def create
    @timing = Timing.new(params[:timing].slice(:start,:stop,:days,:parent_class,:parent_id))
    if @timing.save
      render json: @timing
    else
      render json: { error: "error: could not save timing" }
    end
  end

  # PUT /timings/1
  # PUT /timings/1.json
  def update
    @timing = Timing.find(params[:id])
    if @timing.update_attributes(params[:timing].slice(:start,:stop,:days))
      render json: @timing
    else 
      render json: { error: "error: could not update timing" }      
    end
  end


end
