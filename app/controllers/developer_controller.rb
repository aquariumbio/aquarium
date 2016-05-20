class DeveloperController < ApplicationController

  before_filter :signed_in_user

  def developer
    respond_to do |format|
      format.html { render layout: 'developer' }
    end    
  end

  def get

    path = params[:path] + ".rb"    

    begin
      sha = Repo::version path
      content = Repo::contents path, sha
      render json: { path: path, sha: sha, content: content, errors: [] }
    rescue Exception => e
      render json: { errors: [ e.to_s ] }
    end

  end

  def save

    path = params[:path] + ".rb"

    begin
      sha = Repo::save path, params[:content]
      render json: { errors: [], sha: sha }
    rescue Exception => e
      render json: { errors: [ e.to_s ] }
    end

  end

  def test

    path = params[:path] + ".rb"

    begin
      sha = Repo::version path
    rescue Exception => e
      render json: { errors: [ e.to_s ] }
      return
    end

    job = Job.new
    job.path = path
    job.sha = sha

    # Set up job parameters
    job.pc = Job.NOT_STARTED
    job.set_arguments params[:arguments]
    job.group_id = Group.find_by_name('admin').id
    job.submitted_by = current_user.id
    job.user_id = current_user.id
    job.desired_start_time = DateTime.now
    job.latest_start_time = DateTime.now + 1.hour

    # Save the job
    job.save

    result = Krill::Client.new.start job.id, true # debug

    if result[:response] == "error"
      render json: { errors: [ "Krill could not start #{job.id}" ] + result[:error].split(",")[0,5] }
      return
    end

    job.reload

    if job.error?
      render json: { errors: [ "Job #{job.id} failed" ], job: job }
    else
      render json: { job: job }      
    end

  end    

end
