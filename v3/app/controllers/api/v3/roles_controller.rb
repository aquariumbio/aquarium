class Api::V3::RolesController < ApplicationController

  def get_roles
    ip = request.remote_ip
    token = params[:token].to_s.strip.downcase

    status, user = User.validate_token({:ip => ip, :token => token})
    case status
      when 400
        render :json => { :status => 400, :error => "Invalid." }.to_json and return
      when 401
        render :json => { :status => 401, :error => "Session timeout." }.to_json and return
      when 403
        render :json => { :status => 403, :error => "Permissions required." }.to_json and return
      when 200
        # noop
      end

    roles = Role.role_ids

    render :json => { :status => 200, :data => { :roles => roles } }.to_json
  end

end
