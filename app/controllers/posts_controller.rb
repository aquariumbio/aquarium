class PostsController < ApplicationController

  before_filter :signed_in_user

  def index

    if params[:klass]

      # Called on a specific object
      #  klass (job,item,sample,task)
      #  key (id or sha)

      field = (params[:klass].downcase + '_id').to_sym
      key = params[:key]
      @posts = PostAssociation.get field, key

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @posts.as_json, layout: 'plugin' }
      end

    else

      # Called with no object in particular

      respond_to do |format|
        format.html do
          render layout: 'plugin.html.erb'
        end
        format.json do
          # Post.where(:published => true).paginate(:page => params[:page]).order('id DESC')
          begin
            posts = Post.where(parent_id: nil).paginate(page: params[:page].to_i + 1).order('posts.updated_at DESC')
            render json: posts.as_json
          rescue Exception => e
            posts = Post.where(parent_id: nil).order('posts.updated_at DESC')
            render json: posts.as_json
          end

        end
      end

    end

  end

  def create
    if params[:data][:parent_id]
      reply
    else
      new_post
    end
  end

  def reply

    begin
      p = Post.new content: params[:data][:content], user_id: current_user.id, parent_id: params[:data][:parent_id]
      p.save
    rescue Exception => e
      render json: { error: 'Could not create post: ' + e.to_s }
      return
    end

    render json: p.as_json

  end

  def new_post

    begin
      p = Post.new content: params[:data][:content], user_id: current_user.id
      p.save

      if params[:data][:klass]
        pa = PostAssociation.new post_id: p.id
        if params[:data][:klass] == 'Protocol'
          pa[:sha] = params[:data][:key]
        else
          pa[(params[:data][:klass].downcase + '_id').to_sym] = params[:data][:key]
        end
        pa.save
      end
    rescue Exception => e
      logger.info e.to_s + ': ' + e.backtrace.join(',')
      render json: { error: 'Could not create post: ' + e.to_s }
      return
    end

    render json: p.as_json

  end

end
