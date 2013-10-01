class JobsController < ApplicationController

  before_filter :signed_in_user

  def index

    @user_id = params[:user_id] ? params[:user_id] : current_user.id
    @user = User.find(@user_id)

    @active_jobs = Job.where("user_id = ? AND pc >= -1", @user_id)
    @completed_jobs = Job.where("user_id = ? AND pc = -2", @user_id).order('id DESC')

  end

  def show
    @job = Job.find(params[:id])
  end

  def destroy
    Job.find(params[:id]).destroy
    flash[:success] = "Job #{params[:id]} has been cancelled."
    redirect_to jobs_url
  end

end
