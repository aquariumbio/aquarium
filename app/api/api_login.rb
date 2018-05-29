module ApiLogin

  def login

    @user = User.find_by(login: params[:login])

    if @user && @user.key == params[:key]
      return true
    else
      error 'Invalid user / key combination'
      return false
    end

  end

end
