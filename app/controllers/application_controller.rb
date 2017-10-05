class ApplicationController < ActionController::Base
  include SessionsHelper

  # CSRF handling. CSRF tokens are needed as long as we have cookies that affect the state of the system 
  # especially for authentication (see https://security.stackexchange.com/a/166798 for discussion).
  #
  # (Details here correspond to changes to $httpProvider defaults in angular_initialize.js)
  # 1. Using angular_rails_csrf gem modified to allow renaming of cookie
  # 2. indicate that we are using CSRF 

  protect_from_forgery

  # 3. Handle error
  def handle_unverified_request
    # Force signout to prevent CSRF attacks
    sign_out
    super
  end

  # CSRF Notes:
  # After Rails 4 use
  #
  #   protect_from_forgery with: :exception
  #
  # with 
  #
  #   rescue_from ActionController::InvalidAuthenticityToken do |_exception|
  #      sign_out
  #   end
  #
  # Rails 5 documentation http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
  # suggests turning this off for API/JSON, but should only be done if have no cookies as described above
  #
  #   protect_from_forgery unless: -> { request.format.json? } 

  def sequence_new_job(sha, path, from)
    data = ''

    begin
      data = (Job.find(from).logs.select { |j| j.entry_type == 'return' }).first.data
      retval = JSON.parse(data, symbolize_names: true)
    rescue Exception => e
      flash[:notice] = "Could not parse JSON for return value of job #{from}: " + e.to_s
      redirect_to repo_list_path
      return
    end

    scope = Lang::Scope.new {}

    retval.each do |k, v|
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
