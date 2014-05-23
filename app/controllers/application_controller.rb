# class ExpectionMailer < ActionMailer::Base
#   #default from: 'bioturk@localhost'

#   def error_email e
#     @e = e
#     mail(to: 'klavins@uw.edu', subject: "Aquarium error")
#   end

# end

class ApplicationController < ActionController::Base

  protect_from_forgery

  include SessionsHelper

#  rescue_from Exception do |e|
#    ExpectionMailer.error_email(e).deliver
#    raise e
#  end

  # Force signout to prevent CSRF attacks
  def handle_unverified_request
    sign_out
    super
  end

  def sequence_new_job sha, path, from

    data = ""

    begin
      data = (Job.find(from).logs.select { |j| j.entry_type == 'return' }).first.data  
      retval = JSON.parse(data,symbolize_names: true)
    rescue Exception => e
      flash[:notice] = "Could not parse JSON for return value of job #{from}: " + e.to_s
      redirect_to repo_list_path
      return
    end

    scope = Lang::Scope.new {}

    retval.each do |k,v|
      scope.set k, v
    end

    scope.push

    job = Job.new
    job.sha = sha
    job.path = path
    job.desired_start_time = Time.now
    job.latest_start_time = Time.now + 1.day
    job.group_id = Group.find_by_name(User.find(current_user.id).login).id
    job.submitted_by = current_user.id
    job.user_id = current_user.id
    job.pc = Job.NOT_STARTED
    job.state = { stack: scope.stack }.to_json
    job.save

    redirect_to jobs_path

  end


end
