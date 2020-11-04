class Api::V3::RolesController < ApplicationController

  def get_roles
    result = check_token_for_permission()
    render :json => result.to_json and return if result[:error]

    roles = Role.role_ids

    render :json => { :status => 200, :data => { :roles => roles } }.to_json
  end

end
