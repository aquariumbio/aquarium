class FoldersController < ApplicationController 

  before_filter :signed_in_user

  def index

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: route }
    end

  end

  def route

    if params[:method]

      logger.info "here: params=#{params}"

      case params[:method]

        when 'new'

          parent_id = params[:parent_id].to_i > 0 ? params[:parent_id].to_i : nil

          f = Folder.new({
               name: 'New Folder', 
               user_id: current_user.id, 
               parent_id: parent_id })

          f.save

          { folder: { id: f.id, name: f.name } }

        when 'delete'

          f = Folder.find(params[:folder_id])
          Folder.trash f

          { result: "ok" }

        when 'rename'
          f = Folder.find(params[:folder_id])
          f.name = params[:name]
          f.save

          { result: "ok" }

        when 'contents'

          samples = Sample.includes(:folder_contents).where("folder_contents.folder_id = ?",params[:folder_id])

          { samples: samples }

      end

    else 

      { folders: [ Folder.tree(current_user), SampleType.folders ] }

    end

  end

end
