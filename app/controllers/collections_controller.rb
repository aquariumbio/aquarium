class CollectionsController < ApplicationController

  before_filter :signed_in_user

  def show

    collection = Collection.find(params[:id])
    raw = collection.as_json
    raw[:part_matrix] = collection.part_matrix_as_json
    part_ids = []
    raw[:part_matrix].each { |row|
      row.each { |part|
        part_ids << part["id"] if part
      }
    }
    das = DataAssociation.where(parent_class: "Item", parent_id: part_ids)
    raw[:part_matrix].each { |row|
      row.each { |part|
        part[:data_associations] = das.select { |da| da.parent_id == part["id"] } if part
      }
    }
    render json: raw

  end

  def new_collection

    c = Collection.new_collection(ObjectType.find(params[:object_type_id]))
    render json: c

  end

  def assign_sample
    @collection = Collection.find(params[:id])
    @sample = Sample.find(params[:sample_id])
    @collection.assign_sample_to_pairs(@sample, params[:pairs])
    redirect_to action: "show", id: params[:id]
  end

  def delete_selection
    @collection = Collection.find(params[:id])
    @collection.delete_selection(params[:pairs])
    redirect_to action: "show", id: params[:id]
  end

  def save_data_associations

    rval = []

    params[:data_associations].each do |raw_da|
      if raw_da[:id]
        da = DataAssociation.find(raw_da[:id])
        da.object = raw_da[:object]
        da.save
      else
        da = DataAssociation.new(raw_da)
        da.save
      end
      j = da.as_json
      j[:rid] = raw_da[:rid]
      rval << j
    end

    render json: rval

  end

  def raw_matrix
    render json: Collection.find(params[:id]).matrix
  end

end
