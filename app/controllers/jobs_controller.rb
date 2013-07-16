class JobsController < ApplicationController

  def index
    @jobs = Job.find(:all, :order => 'id desc')
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
