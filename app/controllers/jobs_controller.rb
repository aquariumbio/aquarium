class JobsController < ApplicationController

  before_filter :signed_in_user

  def index

    @user_id = params[:user_id] ? params[:user_id].to_i : current_user.id

    if @user_id == -1

      now = Time.now

      @active_jobs =  Job.where("pc >= 0")
      @urgent_jobs =  Job.where("pc = -1 AND latest_start_time < ?", now)
      @pending_jobs = Job.where("pc = -1 AND desired_start_time < ? AND ? <= latest_start_time", now, now)
      @later_jobs  =  Job.where("pc = -1 AND ? <= desired_start_time", now)

    else

      @user = User.find(@user_id)

      now = Time.now

      @active_jobs =  (Job.where("pc >= 0").reject { |j| !@user.member? j.group_id } )
      @urgent_jobs =  (Job.where("pc = -1 AND latest_start_time < ?", now).reject { |j|  !@user.member? j.group_id })
      @pending_jobs = (Job.where("pc = -1 AND desired_start_time < ? AND ? <= latest_start_time", now, now).reject { |j|  !@user.member? j.group_id })
      @later_jobs  =  (Job.where("pc = -1 AND ? <= desired_start_time", now).reject { |j|  !@user.member? j.group_id })

    end

  end

  def show

    @job = Job.find(params[:id])

    if @job.group_id
      @group = Group.find_by_id(@job.group_id)
    else
      @group = nil
    end

    if @job.user_id.to_i >= 0
      @user =  User.find_by_id(@job.user_id)
    else
      @user = nil
    end

    if @job.submitted_by
      @submitter = User.find_by_id(@job.submitted_by)
    else
      @submitter = nil
    end

    @status = @job.status

  end

  def destroy
    Job.find(params[:id]).destroy
    flash[:success] = "Job #{params[:id]} has been cancelled."
    redirect_to jobs_url
  end

end
