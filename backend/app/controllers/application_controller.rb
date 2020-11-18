# frozen_string_literal: true

# APPLICATION CONTROLLER
class ApplicationController < ActionController::API
  # CHECK THE TOKEN AGAINST SPECIFIC PERMISSION_ID (0 = ANYTHING NOT RETIRED)
  # RETURN STATUS <AND> ( ERROR <OR> USER )
  def check_token_for_permission(permission_id = 0)
    ip = request.remote_ip.to_s
    token = params[:token].to_s.strip.downcase

    User.validate_token(ip: ip, token: token, check_permission_id: permission_id)
  end
end
