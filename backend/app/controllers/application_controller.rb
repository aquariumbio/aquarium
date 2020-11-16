# frozen_string_literal: true

# APPLICATION CONTROLLER
class ApplicationController < ActionController::API
  # CHECK THE TOKEN AGAINST SPECIFIC PERMISSION_ID (0 = ANYTHING NOT RETIRED)
  # RETURN STATUS <AND> ( ERROR <OR> USER )
  def check_token_for_permission(permission_id = 0)
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase

    status_code, datum = User.validate_token({ ip: ip, token: token }, permission_id)
    case status_code
    when 401
      status = "unauthorized"
      response = { error: datum }
    when 403
      status = "forbidden"
      permission = Permission.permission_ids[permission_id]
      error = permission ? "#{permission.capitalize} permissions required." : 'Forbidden.'
      response = { error: error }
    when 200
      status = "ok"
      response = { user: datum }
    end
    return status, response
  end
end
