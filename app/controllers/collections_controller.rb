class CollectionsController < ApplicationController

  before_filter :signed_in_user

  def assign_sample
    @collection = Collection.find(params[:id])
    @sample = Sample.find(params[:sample_id])
    @collection.assign_sample_to_pairs(@sample, params[:pairs])
    render json: @collection.as_json(methods: "part_matrix_as_json")
  end

end
