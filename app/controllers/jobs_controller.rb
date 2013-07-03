class JobsController < ApplicationController

  def index
    @jobs = Job.all
  end

  def destroy
    Job.find(params[:id]).destroy
    flash[:success] = "Job #{params[:id]} has been cancelled."
    redirect_to jobs_url
  end

end
