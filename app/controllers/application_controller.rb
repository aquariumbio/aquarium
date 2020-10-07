# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base

  protect_from_forgery

  skip_before_action :verify_authenticity_token

  around_action :rescue_errors

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

  # Catch unexpected errors
  def rescue_errors
    if Rails.env == "development" and 1==0
      yield
    else
      begin
        yield
      rescue => e
        Rails.logger.info ">>> ERROR BEGIN"
        Rails.logger.info ">>> ERROR MESSAGE"
        Rails.logger.info e.message
        Rails.logger.info ">>> ERROR BACKTRACE"
        e.backtrace.each do |ee|
          Rails.logger.info ee
        end
        Rails.logger.info ">>> ERROR END"
        params[:password] = "********" if params[:password]
        session[:error] = [ url_for(params), e.message, e.backtrace[0] ]

        redirect_to "/error"
      end
    end
  end

end
