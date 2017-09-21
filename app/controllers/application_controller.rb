class ApplicationController < ActionController::Base
  include SessionsHelper

  # Handle CSRF
  protect_from_forgery

  before_filter :set_csrf_names
  after_filter :set_csrf_cookie_for_ng

  def set_csrf_names
    @csrf_cookie_name = "XSRF-TOKEN_#{Bioturk::Application.environment_name}"
    @csrf_header_name = 'X-' + @csrf_cookie_name
  end

  def set_csrf_cookie_for_ng
    cookies[@csrf_cookie_name] = form_authenticity_token if protect_against_forgery?
  end

  # Force signout to prevent CSRF attacks
  def handle_unverified_request
    sign_out
    super
  end

  def sequence_new_job(sha, path, from)
    data = ''

    begin
      data = (Job.find(from).logs.select { |j| j.entry_type == 'return' }).first.data
      retval = JSON.parse(data, symbolize_names: true)
    rescue StandardError => e
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

  protected

  # Handle CSRF request.
  #
  # In Rails 4.1 and below
  # for 4.2 and above use
  #  super || valid_authenticity_token?(session, request.headers[header_name])
  #
  def verified_request?
    super || form_authenticity_token == request.headers[@csrf_header_name]
  end
end
