class OperationTypesController < ApplicationController

  def index
    render json: OperationType.all
  end

end
