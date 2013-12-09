class LogsController < ApplicationController

  before_filter :signed_in_user

  def index

    @user_id = params[:user_id] ? params[:user_id] : current_user.id
    @user = User.find(@user_id)
    @completed_jobs = Job.paginate(page: params[:page], :per_page => 20).where("user_id = ? AND pc = -2", @user_id).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @logs }
    end

  end

  def show
    @log = Log.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @log }
    end
  end

end
