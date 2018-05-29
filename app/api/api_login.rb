# frozen_string_literal: true

module ApiLogin

  def login

    @user = User.find_by_login(params[:login])

    if @user && @user.key == params[:key]
      return true
    else
      error 'Invalid user / key combination'
      return false
    end

  end

end
