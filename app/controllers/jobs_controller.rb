# frozen_string_literal: true

class JobsController < ApplicationController

  before_filter :signed_in_user

  def index

    @users = User.all - User.includes(memberships: :group).where(memberships: { group_id: Group.find_by_name('retired') })
    @groups = Group.includes(:memberships).all.reject { |g| g.memberships.length == 1 }
    @metacols = Metacol.where(status: 'RUNNING')

  end

  def joblist
    logger.info params
    render json: JobsDatatable.new(view_context)
  end

  def show

    begin
      @job = Job.find(params[:id])
    rescue StandardError
      redirect_to logs_path
      return
    end

    return redirect_to krill_log_path(job: @job.id) 

  end

  def destroy
    Job.find(params[:id]).destroy
    flash[:success] = "Job #{params[:id]} has been cancelled."
    redirect_to jobs_url
  end

  def upload
    redirect_to Upload.find(params[:id]).url
  end

end
