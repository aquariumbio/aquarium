# typed: false
# frozen_string_literal: true

class UploadsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def show
    raise ActionController::RoutingError.new('Upload parent type not found') unless params[:type] == 'operation' || params[:type] == 'item' || params[:type] == 'plan'

    das = DataAssociation.associations_for(parent_id: params[:id], parent_class: params[:type].capitalize, key: params[:key])
    raise ActionController::RoutingError.new('Upload Not Found') unless !das.empty? && das[0].upload_id

    viewable_types = ['image/jpeg', 'image/tiff', 'image/png']
    upload = das[0].upload
    raise ActionController::RoutingError.new("Upload file type #{upload.upload_content_type} not viewable") unless viewable_types.member?(upload.upload_content_type)

    file = open(upload.url)
    send_file(file, filename: upload.upload_file_name, disposition: 'inline')
  end
end
