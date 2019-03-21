class UploadsController < ApplicationController

  before_filter :signed_in_user
  before_filter :up_to_date_user

  def show

    if params[:type] == "operation" || params[:type] == 'item' || params[:type] == 'plan'

      das = DataAssociation.where(parent_class: params[:type].capitalize, parent_id: params[:id], key: params[:key])

    else

      raise ActionController::RoutingError.new('Upload parent type not found')       

    end

    if das.length > 0 && das[0].upload_id

      upload = das[0].upload
 

      if ["image/jpeg", 
          "image/tiff",
          "image/png" ].member? upload.upload_content_type

        file = open(upload.url) 
        send_file(file, :filename => upload.upload_file_name, :disposition => "inline")

      else 

        raise ActionController::RoutingError.new('Upload file type #{upload.upload_content_type} not viewable') 

      end

    else

      raise ActionController::RoutingError.new('Upload Not Found') 

    end

  end

end
