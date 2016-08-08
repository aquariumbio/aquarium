class OperationTypesController < ApplicationController

  def index
    render json: OperationType.includes(fts: { allowable_field_types: [ :sample_type, :object_type ] }).all.as_json(include: { fts: { include: { allowable_field_types: { include: [ :sample_type, :object_type ] } } } } )
  end

end

