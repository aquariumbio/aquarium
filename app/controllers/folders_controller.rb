class FoldersController < ApplicationController 

  before_filter :signed_in_user

  def index

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: route }
    end

  end


  def workflow_info wf

    wf

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

          samples = FolderContent
            .includes(sample: {workflow_associations: { workflow_thread: :workflow } })
            .where("folder_id = ? AND sample_id is not null", params[:folder_id] )
            .reverse
            .collect { |fc| fc.sample.for_folder }

          workflows = FolderContent
            .includes(:workflow)
            .where("folder_id = ? AND workflow_id is not null", params[:folder_id] )
            .reverse
            .collect { |fc| workflow_info fc.workflow }

          { samples: samples, workflows: workflows }

        when 'add_sample'

          s = Sample.includes(:sample_type,workflow_associations: { workflow_thread: :workflow }).find(params[:sample_id])
          FolderContent.new(folder_id: params[:folder_id], sample_id: s.id).save

          { sample: s.for_folder }

        when 'thread_parts'

          { parts: WorkflowThread.find(params[:thread_id]).parts(params[:sample_id]) }

      end

    else 

      { folders: [ Folder.tree(current_user), SampleType.folders ] }

    end

  end

end
