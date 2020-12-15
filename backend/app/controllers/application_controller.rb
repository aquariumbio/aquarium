# frozen_string_literal: true
require 'input'

# application_controller
class ApplicationController < ActionController::API
  # Check whether a token has a specific permission_id.
  # permission_id ==  0: anything                                (not retired)
  # permission_id ==  1: admin                                   (not retired)
  # permission_id == -1: admin             or target_id == self  (not retired)
  # permission_id ==  2: manage  or admin                        (not retired)
  # permission_id ==  3: run     or admin                        (not retired)
  # permission_id ==  4: design  or admin                        (not retired)
  # permission_id ==  5: develop or admin                        (not retired)
  # permission_id ==  6: retired
  #
  # @!method check_token_for_permission(token, permission_id, target_id)
  # @param token [String] a token
  # @param permission_id [Int] the specific permission_id to check
  # @return the the status (i.e., ok, unauthorized, forbidden) and either the user or an error
  def check_token_for_permission(permission_id = 0, target_id = 0)
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase

    status_code, datum = User.validate_token({ ip: ip, token: token }, permission_id, target_id)
    case status_code
    when 401
      status = "unauthorized"
      response = { error: datum }
    when 403
      status = "forbidden"
      permission = Permission.permission_ids[permission_id.abs]
      error = permission ? "#{permission.capitalize} permissions required" : 'Forbidden'
      response = { error: error }
    when 200
      status = "ok"
      response = { user: datum }
    end
    return status, response
  end

end
