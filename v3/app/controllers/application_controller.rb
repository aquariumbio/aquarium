class ApplicationController < ActionController::API

  # CHECK THE TOKEN AGAINST SPECIFIC PERMISSION_ID (0 = ANYTHING NOT RETIRED)
  # RETURN STATUS <AND> ( ERROR <OR> USER )
  def check_token_for_permission(permission_id = 0)
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase

    status, user = User.validate_token({:ip => ip, :token => token}, permission_id)
    @result = case status
      when 400
        { :status => 400, :error => "Invalid." }
      when 401
        { :status => 401, :error => "Session timeout." }
      when 403
        permission = Permission.permission_ids[permission_id]
        error = permission ? "#{permission.capitalize} permissions required." : "Forbidden."
        { :status => 403, :error => error }
      when 200
        { :status => 200, :user => user }
      end

  end
end
