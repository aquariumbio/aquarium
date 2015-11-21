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

          samples = FolderContent
            .includes(sample: {workflow_associations: { workflow_thread: :workflow } })
            .where("folder_id = ? AND sample_id is not null", params[:folder_id] )
            .reverse
            .collect { |fc| fc.sample.for_folder }

          workflows = FolderContent
            .includes(:workflow)
            .where("folder_id = ? AND workflow_id is not null", params[:folder_id] )
            .reverse
            .collect { |fc| fc.workflow.for_folder }

          { samples: samples, workflows: workflows }

        when 'add_sample'

          s = Sample.includes(:sample_type,workflow_associations: { workflow_thread: :workflow }).find(params[:sample_id])
          FolderContent.new(folder_id: params[:folder_id], sample_id: s.id).save

          { sample: s.for_folder }

        when 'add_workflow'

          wf = Workflow.find(params[:workflow_id])
          FolderContent.new(folder_id: params[:folder_id], workflow_id: wf.id).save

          { workflow: wf.for_folder }

        when 'get_sample'

          { sample: Sample.find(params[:sample_id]).for_folder }

        when 'new_sample'

          Rails.logger.info "params = #{params}"

          sample = Sample.new({
            sample_type_id: params[:sample][:sample_type_id],
            project: Folder.find(params[:folder_id]).name,
            user_id: current_user.id,
            name: params[:sample][:name],
            description: params[:sample][:description]
            });

          sample.data = params[:sample][:data].to_json
          sample.save

          if sample.errors.empty?
            unless params[:role]
              fc = FolderContent.new(folder_id: params[:folder_id], sample_id: sample.id)
              fc.save
            end
            { sample: sample.for_folder }
          else
            { error: "Could not create sample: " + sample.errors.full_messages.join(', ') }
          end

        when 'remove_sample'

          fc = FolderContent.where(folder_id: params[:folder_id], sample_id: params[:sample_id])
          if fc.length > 0 
            fc[0].destroy
          end

        when 'remove_workflow'

          fc = FolderContent.where(folder_id: params[:folder_id], workflow_id: params[:workflow_id])
          if fc.length > 0 
            fc[0].destroy
          end

        when 'save_sample'

          sample = Sample.find(params[:id])
          sample.name = params[:name]
          sample.description = params[:description]
          sample.data = params[:data].to_json
          sample.save

          if sample.errors.empty?
            { sample: sample.for_folder }
          else
            { error: "Could not save sample: " + sample.errors.full_messages.join(', ') }
          end

        when 'thread_parts'

          { parts: WorkflowThread.find(params[:thread_id]).parts(params[:sample_id]) }

        when 'threads'

          { threads: WorkflowThread
                       .includes(:user)
                       .where(workflow_id: params[:workflow_id], process_id: nil)
                       .as_json(include: :user) 
          }

      end

    else 

      { folders: [ Folder.tree(current_user), Workflow.folders, User.folders(current_user) ] }

    end

  end

end
