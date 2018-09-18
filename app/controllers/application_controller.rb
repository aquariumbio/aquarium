class ApplicationController < ActionController::Base

  protect_from_forgery

  skip_before_action :verify_authenticity_token 

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

end
